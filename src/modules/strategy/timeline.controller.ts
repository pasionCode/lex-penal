import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { StrategyService } from './strategy.service';
import { CreateTimelineEntryDto } from './dto/create-timeline-entry.dto';

/**
 * GET  /api/v1/cases/:id/timeline
 * POST /api/v1/cases/:id/timeline
 * linea_tiempo: append-only (MODELO_DATOS_v3 — Principio 2).
 * UNIQUE (caso_id, orden) en BD.
 */
@Controller('cases/:caseId/timeline')
export class TimelineController {
  constructor(private readonly service: StrategyService) {}

  @Get()
  findAll(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Post()
  create(@Param('caseId') _id: string, @Body() _dto: CreateTimelineEntryDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
