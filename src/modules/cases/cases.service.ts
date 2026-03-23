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
import { EstadoCaso, PerfilUsuario } from '../../types/enums';

/**
 * Orquesta CRUD del caso y delega transiciones a CasoEstadoService.
 * R08: al activar (borrador→en_analisis) crea estructura base atómica.
 * R09: cerrado es inmutable — verificar antes de delegar a herramientas.
 */
@Injectable()
export class CasesService {
  constructor(private readonly repository: CasesRepository) {}

  /**
   * Crea un caso nuevo en estado borrador.
   * Asigna responsable_id, creado_por y actualizado_por desde el usuario autenticado.
   *
   * @throws BadRequestException si el cliente no existe
   * @throws ConflictException si el radicado ya está registrado
   */
  async create(dto: CreateCaseDto, userId: string): Promise<Caso> {
    // 1. Validar que el cliente existe
    const clienteExists = await this.repository.clienteExists(dto.cliente_id);
    if (!clienteExists) {
      throw new BadRequestException(`El cliente ${dto.cliente_id} no existe`);
    }

    // 2. Validar radicado único
    const existente = await this.repository.findByRadicado(dto.radicado);
    if (existente) {
      throw new ConflictException(`El radicado ${dto.radicado} ya está registrado en el sistema`);
    }

    // 3. Crear caso con ownership del usuario autenticado
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

  /**
   * Lista casos del usuario (ownership).
   * Supervisor/Admin ven todos.
   */
  async findAll(userId: string, perfil: PerfilUsuario): Promise<Caso[]> {
    if (perfil === PerfilUsuario.SUPERVISOR || perfil === PerfilUsuario.ADMINISTRADOR) {
      return this.repository.findAll();
    }
    return this.repository.findByResponsable(userId);
  }

  /**
   * Obtiene un caso por ID con relaciones básicas.
   * Verifica acceso según perfil en una sola consulta.
   *
   * @throws NotFoundException si el caso no existe
   * @throws ForbiddenException si no tiene acceso
   */
  async findOne(id: string, userId: string, perfil: PerfilUsuario) {
    const caso = await this.repository.findByIdWithRelations(id);
    
    if (!caso) {
      throw new NotFoundException(`Caso ${id} no encontrado`);
    }

    // Estudiante solo accede a sus propios casos
    if (perfil === PerfilUsuario.ESTUDIANTE && caso.responsable_id !== userId) {
      throw new ForbiddenException('Sin acceso a este caso');
    }

    return caso;
  }

  /**
   * Verifica que el usuario tiene acceso al caso.
   * Usado por endpoints que necesitan validar antes de otra operación.
   *
   * @throws NotFoundException si el caso no existe
   * @throws ForbiddenException si no tiene acceso
   */
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
