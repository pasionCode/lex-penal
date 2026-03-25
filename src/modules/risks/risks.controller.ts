import {
  Controller,
  Get,
  Post,
  Put,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { RisksService } from './risks.service';
import { CreateRiskDto } from './dto/create-risk.dto';
import { UpdateRiskDto } from './dto/update-risk.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * CRUD individual de riesgos del caso.
 */
@Controller('cases/:caseId/risks')
@UseGuards(JwtAuthGuard)
export class RisksController {
  constructor(private readonly service: RisksService) {}

  @Post()
  async create(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: CreateRiskDto,
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

  @Get(':riskId')
  async findOne(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('riskId', ParseUUIDPipe) riskId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findOne(caseId, riskId, user.sub, user.perfil as PerfilUsuario);
  }

  @Put(':riskId')
  async update(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('riskId', ParseUUIDPipe) riskId: string,
    @Body() dto: UpdateRiskDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.update(caseId, riskId, dto, user.sub, user.perfil as PerfilUsuario);
  }
}
