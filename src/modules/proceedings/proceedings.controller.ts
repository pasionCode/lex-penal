import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ProceedingsService } from './proceedings.service';
import { CreateProceedingDto } from './dto/create-proceeding.dto';
import { UpdateProceedingDto } from './dto/update-proceeding.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * CRUD de actuaciones procesales del caso.
 * GET    /api/v1/cases/:caseId/proceedings              → Listar
 * POST   /api/v1/cases/:caseId/proceedings              → Crear
 * GET    /api/v1/cases/:caseId/proceedings/:proceedingId → Detalle
 * PUT    /api/v1/cases/:caseId/proceedings/:proceedingId → Editar
 * DELETE /api/v1/cases/:caseId/proceedings/:proceedingId → Eliminar
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

  @Put(':proceedingId')
  async update(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('proceedingId', ParseUUIDPipe) proceedingId: string,
    @Body() dto: UpdateProceedingDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.update(caseId, proceedingId, dto, user.sub, user.perfil as PerfilUsuario);
  }

  @Delete(':proceedingId')
  async remove(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('proceedingId', ParseUUIDPipe) proceedingId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.remove(caseId, proceedingId, user.sub, user.perfil as PerfilUsuario);
  }
}
