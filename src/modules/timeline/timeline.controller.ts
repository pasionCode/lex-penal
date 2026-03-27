import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  Query,
  UseGuards,
  ParseUUIDPipe,
  ParseIntPipe,
  DefaultValuePipe,
} from '@nestjs/common';
import { TimelineService } from './timeline.service';
import { CreateTimelineEntryDto } from './dto/create-timeline-entry.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * Línea de tiempo del caso — append-only.
 * GET  /api/v1/cases/:caseId/timeline
 * POST /api/v1/cases/:caseId/timeline
 */
@Controller('cases/:caseId/timeline')
@UseGuards(JwtAuthGuard)
export class TimelineController {
  constructor(private readonly service: TimelineService) {}

  @Get()
  async findAll(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('per_page', new DefaultValuePipe(20), ParseIntPipe) perPage: number,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findByCaseId(
      caseId,
      user.sub,
      user.perfil as PerfilUsuario,
      page,
      perPage,
    );
  }

  @Post()
  async create(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: CreateTimelineEntryDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.create(caseId, dto, user.sub, user.perfil as PerfilUsuario);
  }
}
