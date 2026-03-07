import { Controller, Get, Param, Query } from '@nestjs/common';
import { AuditService } from './audit.service';
import { QueryAuditDto } from './dto/query-audit.dto';

/**
 * GET /api/v1/cases/:id/audit  → log de eventos del caso
 * Acceso: solo Supervisor y Administrador (R06).
 * El endpoint expone solo metadatos — NO prompt_enviado ni respuesta_recibida
 * de ai_request_log (ARQUITECTURA_MODULO_IA_v3).
 */
@Controller('api/v1/cases/:caseId/audit')
export class AuditController {
  constructor(private readonly service: AuditService) {}

  @Get()
  findAll(
    @Param('caseId') _caseId: string,
    @Query() _query: QueryAuditDto,
  ): Promise<unknown> {
    throw new Error('not implemented');
  }
}
