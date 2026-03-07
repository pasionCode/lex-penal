import { Body, Controller, Delete, Get, Param, Post, Put } from '@nestjs/common';
import { StrategyService } from './strategy.service';
import { CreateProceedingDto, UpdateStrategyDto } from './dto/update-strategy.dto';

/**
 * GET  /api/v1/cases/:id/strategy
 * PUT  /api/v1/cases/:id/strategy
 * Campos: linea_principal (obligatorio para pendiente_revision),
 * fundamento_juridico, fundamento_probatorio, linea_subsidiaria,
 * posicion_allanamiento, posicion_preacuerdo, posicion_juicio.
 *
 * GET    /api/v1/cases/:id/proceedings
 * POST   /api/v1/cases/:id/proceedings
 * PUT    /api/v1/cases/:id/proceedings/:proc_id
 * DELETE /api/v1/cases/:id/proceedings/:proc_id
 */
@Controller('api/v1/cases/:caseId')
export class StrategyController {
  constructor(private readonly service: StrategyService) {}

  @Get('strategy')
  getStrategy(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put('strategy')
  updateStrategy(@Param('caseId') _id: string, @Body() _dto: UpdateStrategyDto): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Get('proceedings')
  getProceedings(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Post('proceedings')
  createProceeding(@Param('caseId') _id: string, @Body() _dto: CreateProceedingDto): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put('proceedings/:procId')
  updateProceeding(
    @Param('caseId') _caseId: string,
    @Param('procId') _procId: string,
    @Body() _dto: CreateProceedingDto,
  ): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Delete('proceedings/:procId')
  deleteProceeding(
    @Param('caseId') _caseId: string,
    @Param('procId') _procId: string,
  ): Promise<unknown> {
    throw new Error('not implemented');
  }
}
