import { Controller, Get, Post, Put, Param, Body } from '@nestjs/common';
import { CasesService } from './cases.service';
import { CreateCaseDto } from './dto/create-case.dto';
import { TransitionStateDto } from './dto/transition-state.dto';
import { UpdateCaseDto } from './dto/update-case.dto';

/**
 * Agregado raíz del caso:
 * GET    /api/v1/cases
 * POST   /api/v1/cases
 * GET    /api/v1/cases/:id
 * PUT    /api/v1/cases/:id
 * POST   /api/v1/cases/:id/transition
 *
 * Reglas de estado (ADR-003, R08, R09):
 * - borrador → no acepta escritura en herramientas
 * - cerrado  → inmutable en todas las herramientas
 * - Estado solo modificable por CasoEstadoService
 */
@Controller('api/v1/cases')
export class CasesController {
  constructor(private readonly service: CasesService) {}

  @Get()
  findAll(): Promise<unknown> { throw new Error('not implemented'); }

  @Post()
  create(@Body() _dto: CreateCaseDto): Promise<unknown> { throw new Error('not implemented'); }

  @Get(':id')
  findOne(@Param('id') _id: string): Promise<unknown> { throw new Error('not implemented'); }

  @Put(':id')
  update(@Param('id') _id: string, @Body() _dto: UpdateCaseDto): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Post(':id/transition')
  transition(@Param('id') _id: string, @Body() _dto: TransitionStateDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
