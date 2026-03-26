import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ProceedingsService } from './proceedings.service';
import { CreateProceedingDto } from './dto/create-proceeding.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * Actuaciones procesales del caso — Política Append-Only (Sprint 13)
 * 
 * GET    /api/v1/cases/:caseId/proceedings              → Listar
 * POST   /api/v1/cases/:caseId/proceedings              → Crear
 * GET    /api/v1/cases/:caseId/proceedings/:proceedingId → Detalle
 * 
 * PUT y DELETE removidos por política append-only.
 */
@Controller('cases/:caseId/proceedings')
@UseGuards(JwtAuthGuard)
export class ProceedingsController {
  constructor(private readonly service: ProceedingsService) {}

  @Get()
  async findAll(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findAll(caseId, user.sub, user.perfil as PerfilUsuario);
  }

  @Post()
  async create(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: CreateProceedingDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.create(caseId, dto, user.sub, user.perfil as PerfilUsuario);
  }

  @Get(':proceedingId')
  async findOne(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('proceedingId', ParseUUIDPipe) proceedingId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findOne(caseId, proceedingId, user.sub, user.perfil as PerfilUsuario);
  }
}
