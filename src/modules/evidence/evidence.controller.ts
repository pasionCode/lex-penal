import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { EvidenceService } from './evidence.service';
import { CreateEvidenceDto } from './dto/create-evidence.dto';
import { UpdateEvidenceDto } from './dto/update-evidence.dto';
import { LinkEvidenceDto } from './dto/link-evidence.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * CRUD individual de pruebas del caso + vínculo a hecho.
 */
@Controller('cases/:caseId/evidence')
@UseGuards(JwtAuthGuard)
export class EvidenceController {
  constructor(private readonly service: EvidenceService) {}

  @Post()
  async create(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: CreateEvidenceDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.create(caseId, dto, user.sub, user.perfil as PerfilUsuario);
  }

  @Get()
  async findAll(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findByCaseId(caseId, user.sub, user.perfil as PerfilUsuario);
  }

  @Get(':evidenceId')
  async findOne(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('evidenceId', ParseUUIDPipe) evidenceId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findOne(caseId, evidenceId, user.sub, user.perfil as PerfilUsuario);
  }

  @Put(':evidenceId')
  async update(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('evidenceId', ParseUUIDPipe) evidenceId: string,
    @Body() dto: UpdateEvidenceDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.update(caseId, evidenceId, dto, user.sub, user.perfil as PerfilUsuario);
  }

  @Patch(':evidenceId/link')
  async link(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('evidenceId', ParseUUIDPipe) evidenceId: string,
    @Body() dto: LinkEvidenceDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.link(caseId, evidenceId, dto.hecho_id, user.sub, user.perfil as PerfilUsuario);
  }

  @Patch(':evidenceId/unlink')
  async unlink(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('evidenceId', ParseUUIDPipe) evidenceId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.unlink(caseId, evidenceId, user.sub, user.perfil as PerfilUsuario);
  }
}