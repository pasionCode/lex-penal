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
import { CasesService } from './cases.service';
import { CreateCaseDto } from './dto/create-case.dto';
import { TransitionStateDto } from './dto/transition-state.dto';
import { UpdateCaseDto } from './dto/update-case.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

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
@Controller('cases')
@UseGuards(JwtAuthGuard)
export class CasesController {
  constructor(private readonly service: CasesService) {}

  /**
   * US-07: Lista casos del usuario autenticado.
   * Estudiante ve solo sus casos; Supervisor/Admin ven todos.
   */
  @Get()
  async findAll(@CurrentUser() user: JwtPayload) {
    return this.service.findAll(user.sub, user.perfil as PerfilUsuario);
  }

  /**
   * US-06: Crea un caso nuevo en estado borrador.
   * El usuario autenticado queda como responsable y creador.
   */
  @Post()
  async create(
    @Body() dto: CreateCaseDto,
    @CurrentUser('sub') userId: string,
  ) {
    return this.service.create(dto, userId);
  }

  /**
   * US-08: Consulta detalle de un caso.
   */
  @Get(':id')
  async findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findOne(id, user.sub, user.perfil as PerfilUsuario);
  }

 /**
   * US-10: Actualiza metadata editable del caso.
   */
  @Put(':id')
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCaseDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.update(id, dto, user.sub, user.perfil as PerfilUsuario);
  }

  /**
   * US-09: Transiciona el estado del caso.
   */
  @Post(':id/transition')
  async transition(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: TransitionStateDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.transition(
      id,
      dto.estado_destino,
      user.sub,
      user.perfil as PerfilUsuario,
      dto.observaciones,
    );
  }

}
