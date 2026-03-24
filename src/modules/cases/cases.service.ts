import {
  Injectable,
  ConflictException,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { Caso } from '@prisma/client';
import { CasesRepository } from './cases.repository';
import { CreateCaseDto } from './dto/create-case.dto';
import { UpdateCaseDto } from './dto/update-case.dto';
import { EstadoCaso, PerfilUsuario } from '../../types/enums';

@Injectable()
export class CasesService {
  constructor(private readonly repository: CasesRepository) {}

  async create(dto: CreateCaseDto, userId: string): Promise<Caso> {
    const clienteExists = await this.repository.clienteExists(dto.cliente_id);
    if (!clienteExists) {
      throw new BadRequestException(`El cliente ${dto.cliente_id} no existe`);
    }

    const existente = await this.repository.findByRadicado(dto.radicado);
    if (existente) {
      throw new ConflictException(`El radicado ${dto.radicado} ya está registrado en el sistema`);
    }

    return this.repository.create({
      cliente: { connect: { id: dto.cliente_id } },
      responsable: { connect: { id: userId } },
      creador: { connect: { id: userId } },
      actualizador: { connect: { id: userId } },
      radicado: dto.radicado,
      delito_imputado: dto.delito_imputado,
      regimen_procesal: dto.regimen_procesal,
      etapa_procesal: dto.etapa_procesal,
      despacho: dto.despacho ?? null,
      fecha_apertura: dto.fecha_apertura ? new Date(dto.fecha_apertura) : null,
      estado_actual: EstadoCaso.BORRADOR,
    });
  }

  async findAll(userId: string, perfil: PerfilUsuario): Promise<Caso[]> {
    if (perfil === PerfilUsuario.SUPERVISOR || perfil === PerfilUsuario.ADMINISTRADOR) {
      return this.repository.findAll();
    }
    return this.repository.findByResponsable(userId);
  }

  async findOne(id: string, userId: string, perfil: PerfilUsuario) {
    const caso = await this.repository.findByIdWithRelations(id);
    
    if (!caso) {
      throw new NotFoundException(`Caso ${id} no encontrado`);
    }

    if (perfil === PerfilUsuario.ESTUDIANTE && caso.responsable_id !== userId) {
      throw new ForbiddenException('Sin acceso a este caso');
    }

    return caso;
  }

  async update(
    id: string,
    dto: UpdateCaseDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Caso> {
    const caso = await this.checkAccess(id, userId, perfil);

    const estadosEditables = [EstadoCaso.EN_ANALISIS, EstadoCaso.DEVUELTO];
    if (!estadosEditables.includes(caso.estado_actual as EstadoCaso)) {
      throw new ConflictException(
        `El caso en estado "${caso.estado_actual}" no permite edicion`,
      );
    }

    const updateData: Record<string, unknown> = {
      actualizado_por: userId,
    };

    if (dto.despacho !== undefined) updateData.despacho = dto.despacho;
    if (dto.etapa_procesal !== undefined) updateData.etapa_procesal = dto.etapa_procesal;
    if (dto.regimen_procesal !== undefined) updateData.regimen_procesal = dto.regimen_procesal;
    if (dto.proxima_actuacion !== undefined) updateData.proxima_actuacion = dto.proxima_actuacion;
    if (dto.fecha_proxima_actuacion !== undefined) {
      updateData.fecha_proxima_actuacion = new Date(dto.fecha_proxima_actuacion);
    }
    if (dto.responsable_proxima_actuacion !== undefined) {
      updateData.responsable_proxima_actuacion = dto.responsable_proxima_actuacion;
    }
    if (dto.observaciones !== undefined) updateData.observaciones = dto.observaciones;
    if (dto.agravantes !== undefined) updateData.agravantes = dto.agravantes;

    return this.repository.update(id, updateData);
  }

  async transition(
    id: string,
    estadoDestino: EstadoCaso,
    userId: string,
    perfil: PerfilUsuario,
    observaciones?: string,
  ): Promise<Caso> {
    const caso = await this.checkAccess(id, userId, perfil);

    const transicionesPermitidas: Record<EstadoCaso, EstadoCaso[]> = {
      [EstadoCaso.BORRADOR]: [EstadoCaso.EN_ANALISIS],
      [EstadoCaso.EN_ANALISIS]: [EstadoCaso.PENDIENTE_REVISION],
      [EstadoCaso.PENDIENTE_REVISION]: [EstadoCaso.APROBADO_SUPERVISOR, EstadoCaso.DEVUELTO],
      [EstadoCaso.DEVUELTO]: [EstadoCaso.EN_ANALISIS],
      [EstadoCaso.APROBADO_SUPERVISOR]: [EstadoCaso.LISTO_PARA_CLIENTE],
      [EstadoCaso.LISTO_PARA_CLIENTE]: [EstadoCaso.CERRADO],
      [EstadoCaso.CERRADO]: [],
    };

    const estadoActual = caso.estado_actual as EstadoCaso;
    const permitidos = transicionesPermitidas[estadoActual] || [];

    if (!permitidos.includes(estadoDestino)) {
      throw new ConflictException(
        `Transicion de "${estadoActual}" a "${estadoDestino}" no permitida`,
      );
    }

    return this.repository.update(id, {
      estado_actual: estadoDestino,
      estado_anterior: estadoActual,
      fecha_cambio_estado: new Date(),
      usuario_cambio_estado: userId,
      actualizado_por: userId,
      observaciones: observaciones ?? caso.observaciones,
    });
  }

  async checkAccess(casoId: string, userId: string, perfil: PerfilUsuario): Promise<Caso> {
    const caso = await this.repository.findById(casoId);
    if (!caso) {
      throw new NotFoundException(`Caso ${casoId} no encontrado`);
    }

    if (perfil === PerfilUsuario.ESTUDIANTE && caso.responsable_id !== userId) {
      throw new ForbiddenException('Sin acceso a este caso');
    }

    return caso;
  }
}