import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { EvidenceService } from './evidence.service';
import { UpdateEvidenceDto } from './dto/update-evidence.dto';

/**
 * GET /api/v1/cases/:id/evidence
 * PUT /api/v1/cases/:id/evidence → reemplaza el conjunto completo
 * Campos canónicos: descripcion, tipo_prueba, hecho_id,
 * hecho_descripcion_libre, licitud, legalidad, suficiencia,
 * credibilidad, posicion_defensiva (MODELO_DATOS_v3).
 * hecho_id si diligenciado debe pertenecer al mismo caso (integridad cruzada).
 */
@Controller('api/v1/cases/:caseId/evidence')
export class EvidenceController {
  constructor(private readonly service: EvidenceService) {}

  @Get()
  findAll(@Param('caseId') _caseId: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  replace(@Param('caseId') _caseId: string, @Body() _dto: UpdateFactsDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
