import { Controller, Get, Post, Param, Body, Query } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { GenerateReportDto } from './dto/generate-report.dto';

/**
 * GET  /api/v1/cases/:id/reports            → historial de informes generados
 * POST /api/v1/cases/:id/reports            → solicita generación de informe
 * GET  /api/v1/cases/:id/reports/:reportId  → descarga informe
 *
 * Los informes se generan exclusivamente en backend (PI-01).
 * Todo informe queda registrado en informes_generados (PI-02).
 * Idempotencia: mismo tipo+formato en <5 min retorna el existente (PI-04).
 * 409: estado del caso no permite ese informe.
 * 422: faltan datos para generarlo.
 */
@Controller('cases/:caseId/reports')
export class ReportsController {
  constructor(private readonly service: ReportsService) {}

  @Get()
  findAll(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Post()
  generate(@Param('caseId') _id: string, @Body() _dto: GenerateReportDto): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Get(':reportId')
  download(
    @Param('caseId') _caseId: string,
    @Param('reportId') _reportId: string,
    @Query('format') _format: string,
  ): Promise<unknown> {
    throw new Error('not implemented');
  }
}
