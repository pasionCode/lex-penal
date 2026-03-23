import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { FactsService } from './facts.service';
import { UpdateFactsDto } from './dto/update-facts.dto';

/**
 * GET /api/v1/cases/:id/facts
 * PUT /api/v1/cases/:id/facts  → reemplaza el conjunto completo
 * Solo lectura en pendiente_revision y posteriores (R09 parcial).
 * Campos: descripcion, estado_hecho, fuente, incidencia_juridica (MODELO_DATOS_v3).
 */
@Controller('cases/:caseId/facts')
export class FactsController {
  constructor(private readonly service: FactsService) {}

  @Get()
  findAll(@Param('caseId') _caseId: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  replace(@Param('caseId') _caseId: string, @Body() _dto: UpdateFactsDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
