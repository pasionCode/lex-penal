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
import { FactsService } from './facts.service';
import { CreateFactDto } from './dto/create-fact.dto';
import { UpdateFactDto } from './dto/update-fact.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * CRUD individual de hechos del caso.
 * POST   /api/v1/cases/:caseId/facts           → Crear hecho
 * GET    /api/v1/cases/:caseId/facts           → Listar hechos
 * GET    /api/v1/cases/:caseId/facts/:factId   → Detalle
 * PUT    /api/v1/cases/:caseId/facts/:factId   → Editar
 */
@Controller('cases/:caseId/facts')
@UseGuards(JwtAuthGuard)
export class FactsController {
  constructor(private readonly service: FactsService) {}

  /**
   * US-11: Crear hecho en el caso.
   */
  @Post()
  async create(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: CreateFactDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.create(caseId, dto, user.sub, user.perfil as PerfilUsuario);
  }

  /**
   * US-12: Listar hechos del caso.
   */
  @Get()
  async findAll(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findByCaseId(caseId, user.sub, user.perfil as PerfilUsuario);
  }

  /**
   * US-12: Detalle de hecho.
   */
  @Get(':factId')
  async findOne(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('factId', ParseUUIDPipe) factId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findOne(caseId, factId, user.sub, user.perfil as PerfilUsuario);
  }

  /**
   * US-13: Editar hecho.
   */
  @Put(':factId')
  async update(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('factId', ParseUUIDPipe) factId: string,
    @Body() dto: UpdateFactDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.update(caseId, factId, dto, user.sub, user.perfil as PerfilUsuario);
  }
}
