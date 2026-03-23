import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { ChecklistService } from './checklist.service';
import { UpdateChecklistDto } from './dto/update-checklist-item.dto';

/**
 * GET /api/v1/cases/:id/checklist  → bloques con ítems y estado
 * PUT /api/v1/cases/:id/checklist  → marca/desmarca ítems
 *
 * completado del bloque es calculado por backend — no escribible (R02).
 * critico vive en el bloque, NO en el ítem (MODELO_DATOS_v3).
 * Se genera automáticamente al activar el caso (borrador→en_analisis) (R08).
 */
@Controller('cases/:caseId/checklist')
export class ChecklistController {
  constructor(private readonly service: ChecklistService) {}

  @Get()
  get(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  updateItems(@Param('caseId') _id: string, @Body() _dto: UpdateChecklistDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
