import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { AuditService } from './audit.service';
import { QueryAuditDto } from './dto/query-audit.dto';
import { PaginatedAuditResponse } from './dto/audit-response.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * GET /api/v1/cases/:caseId/audit  - Log de eventos del caso
 *
 * Acceso: solo Supervisor y Administrador (R06).
 * Estudiante recibe 403.
 *
 * Filtros opcionales:
 * - tipo: filtra por tipo de evento
 * - page: número de página (default 1)
 * - per_page: items por página (default 20, max 100)
 *
 * El endpoint expone metadatos de eventos. El contenido de AI
 * (prompt_enviado, respuesta_recibida) NO se expone por seguridad.
 */
@Controller('cases/:caseId/audit')
@UseGuards(JwtAuthGuard)
export class AuditController {
  constructor(private readonly service: AuditService) {}

  @Get()
  findAll(
    @Param('caseId') caseId: string,
    @Query() query: QueryAuditDto,
    @CurrentUser() user: JwtPayload,
  ): Promise<PaginatedAuditResponse> {
    return this.service.findAll(
      caseId,
      user.sub,
      user.perfil as PerfilUsuario,
      query,
    );
  }
}
