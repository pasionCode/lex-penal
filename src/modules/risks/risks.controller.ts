import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { RisksService } from './risks.service';
import { UpdateRisksDto } from './dto/update-risks.dto';

/**
 * GET /api/v1/cases/:id/risks
 * PUT /api/v1/cases/:id/risks → reemplaza el conjunto completo
 * Riesgos críticos (prioridad=critica) deben tener estrategia_mitigacion (MODELO_DATOS_v3).
 */
@Controller('api/v1/cases/:caseId/risks')
export class RisksController {
  constructor(private readonly service: RisksService) {}

  @Get()
  findAll(@Param('caseId') _caseId: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  replace(@Param('caseId') _caseId: string, @Body() _dto: UpdateFactsDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
