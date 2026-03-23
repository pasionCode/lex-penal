import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { ConclusionService } from './conclusion.service';
import { UpdateConclusionDto } from './dto/update-conclusion.dto';

/**
 * GET /api/v1/cases/:id/conclusion
 * PUT /api/v1/cases/:id/conclusion  → actualiza campos; todos opcionales por separado
 *
 * Cinco bloques obligatorios para generar informe conclusion_operativa (R03).
 * recomendacion no puede ser nulo para aprobado_supervisor→listo_para_cliente.
 * Estructura completa: MODELO_DATOS_v3 — tabla conclusion_operativa.
 */
@Controller('cases/:caseId/conclusion')
export class ConclusionController {
  constructor(private readonly service: ConclusionService) {}

  @Get()
  get(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  update(@Param('caseId') _id: string, @Body() _dto: UpdateConclusionDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
