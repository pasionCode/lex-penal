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
import { ChecklistService } from '../checklist/checklist.service';
import { CasoEstadoService } from './services/caso-estado.service';

/**
 * Servicio principal de casos.
 *
 * NOTA E5-04: El método transition() ahora delega a CasoEstadoService
 * para ejecutar guardas, persistir revisiones y registrar auditoría.
 * Se conserva checkAccess() para validar que el estudiante sea
 * responsable del caso antes de permitir la transición.
 */
@Injectable()
export class CasesService {
  constructor(
    private readonly repository: CasesRepository,
    private readonly checklistService: ChecklistService,
    private readonly casoEstadoService: CasoEstadoService,
  ) {}

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
      radicado: dto.radicado,
      delito_imputado: dto.delito_imputado,
      despacho: dto.despacho ?? null,
      etapa_procesal: dto.etapa_procesal,
      regimen_procesal: dto.regimen_procesal,
      estado_actual: EstadoCaso.BORRADOR,
      creador: { connect: { id: userId } },
      actualizador: { connect: { id: userId } },
    });
  }

  async findAll(userId: string, perfil: PerfilUsuario): Promise<Caso[]> {
    if (perfil === PerfilUsuario.ESTUDIANTE) {
      return this.repository.findByResponsable(userId);
    }
    return this.repository.findAll();
  }

  async findOne(id: string, userId: string, perfil: PerfilUsuario): Promise<Caso> {
    return this.checkAccess(id, userId, perfil);
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

  /**
   * US-09: Transiciona el estado del caso.
   *
   * E5-04: Delegación a CasoEstadoService.
   *
   * Flujo:
   * 1. checkAccess() - Valida existencia y permisos de acceso (estudiante = solo su caso)
   * 2. casoEstadoService.transicionar() - Ejecuta:
   *    - Validación de matriz de transiciones
   *    - Validación de permisos por perfil
   *    - Verificación de guardas
   *    - Bootstrap de estructura en borrador→en_analisis
   *    - Validación de revisión vigente compatible en devuelto/aprobado_supervisor
   *    - Registro de auditoría
   */
  async transition(
    id: string,
    estadoDestino: EstadoCaso,
    userId: string,
    perfil: PerfilUsuario,
    observaciones?: string,
  ): Promise<Caso> {
    // 1. Validar acceso (estudiante solo puede transicionar su propio caso)
    await this.checkAccess(id, userId, perfil);

    // 2. Delegar a CasoEstadoService (motor completo)
    return this.casoEstadoService.transicionar(
      id,
      estadoDestino,
      userId,
      perfil,
      observaciones ? { observaciones } : undefined,
    );
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
