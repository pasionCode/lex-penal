import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ReviewService } from './review.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * Revisiones del supervisor — append-only.
 * GET  /api/v1/cases/:caseId/review - historial (solo supervisor/admin)
 * POST /api/v1/cases/:caseId/review - crear revisión
 * GET  /api/v1/cases/:caseId/review/feedback - observaciones para estudiante
 */
@Controller('cases/:caseId/review')
@UseGuards(JwtAuthGuard)
export class ReviewController {
  constructor(private readonly service: ReviewService) {}

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
    @Body() dto: CreateReviewDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.create(caseId, dto, user.sub, user.perfil as PerfilUsuario);
  }

  @Get('feedback')
  async getFeedback(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.getFeedback(caseId, user.sub, user.perfil as PerfilUsuario);
  }
}
