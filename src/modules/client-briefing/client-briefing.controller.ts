import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { ClientBriefingService } from './client-briefing.service';
import { UpdateClientBriefingDto } from './dto/update-client-briefing.dto';

/**
 * GET /api/v1/cases/:id/client-briefing
 * PUT /api/v1/cases/:id/client-briefing
 * situacion_libertad del procesado vive en clients, NO aquí (MODELO_DATOS_v3).
 * Campos: delito_explicado, riesgos_informados, panorama_probatorio,
 * beneficios_informados, opciones_explicadas, recomendacion,
 * decision_cliente, fecha_explicacion.
 */
@Controller('cases/:caseId/client-briefing')
export class ClientBriefingController {
  constructor(private readonly service: ClientBriefingService) {}

  @Get()
  get(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  update(@Param('caseId') _id: string, @Body() _dto: UpdateClientBriefingDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
