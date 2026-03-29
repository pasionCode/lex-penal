import {
  Injectable,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { AuditRepository } from './audit.repository';
import { QueryAuditDto } from './dto/query-audit.dto';
import {
  PaginatedAuditResponse,
  AuditEventDto,
  getEventDescription,
} from './dto/audit-response.dto';
import { PerfilUsuario } from '../../types/enums';
import { TipoEvento } from '@prisma/client';

/**
 * Servicio de audit.
 * Orquesta la lógica de negocio del módulo.
 *
 * Reglas de acceso (R06):
 * - Solo supervisor y administrador pueden acceder
 * - Estudiante recibe 403
 *
 * Política de seguridad:
 * - NO se expone metadata ni contenido sensible de AI
 */
@Injectable()
export class AuditService {
  constructor(private readonly repository: AuditRepository) {}

  /**
   * Lista eventos de auditoría de un caso.
   *
   * @param casoId ID del caso
   * @param _userId ID del usuario autenticado (reservado para trazabilidad futura)
   * @param perfil Perfil del usuario autenticado
   * @param query Filtros de consulta
   * @returns Respuesta paginada de eventos
   * @throws ForbiddenException si perfil es estudiante
   * @throws NotFoundException si caso no existe
   */
  async findAll(
    casoId: string,
    _userId: string,
    perfil: PerfilUsuario,
    query: QueryAuditDto,
  ): Promise<PaginatedAuditResponse> {
    // 1. Verificar acceso por perfil
    if (perfil === PerfilUsuario.ESTUDIANTE) {
      throw new ForbiddenException(
        'Acceso restringido a supervisores y administradores',
      );
    }

    // 2. Verificar que el caso existe
    const casoExists = await this.repository.casoExists(casoId);
    if (!casoExists) {
      throw new NotFoundException(`Caso ${casoId} no encontrado`);
    }

    // 3. Convertir tipo de string a enum de Prisma
    const tipoEvento = query.tipo ? (query.tipo as TipoEvento) : undefined;

    // 4. Consultar eventos
    const result = await this.repository.findByCaso(casoId, {
      tipo: tipoEvento,
      page: query.page,
      per_page: query.per_page,
    });

    // 5. Transformar a DTO de respuesta (SIN metadata por política de seguridad)
    const data: AuditEventDto[] = result.data.map((evento) => ({
      id: evento.id,
      tipo: evento.tipo_evento,
      descripcion: getEventDescription(evento.tipo_evento),
      fecha: evento.fecha_evento.toISOString(),
      usuario: {
        id: evento.usuario.id,
        nombre: evento.usuario.nombre,
      },
      estado_origen: evento.estado_origen || undefined,
      estado_destino: evento.estado_destino || undefined,
      resultado: evento.resultado,
    }));

    return {
      data,
      total: result.total,
      page: query.page || 1,
      per_page: query.per_page || 20,
    };
  }
}
