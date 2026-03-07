import { Controller, Get, Post, Param, Body } from '@nestjs/common';
import { ReviewService } from './review.service';
import { CreateReviewDto } from './dto/create-review.dto';

/**
 * GET  /api/v1/cases/:id/review  → historial de revisiones (vigente destacado)
 * POST /api/v1/cases/:id/review  → registra revisión formal
 * GET  /api/v1/cases/:id/review/feedback → observaciones filtradas para estudiante
 *
 * Acceso GET completo: solo Supervisor y Administrador (R04).
 * observaciones obligatorias en aprobado y devuelto.
 * Solo un registro vigente = true por caso (partial unique index).
 */
@Controller('api/v1/cases/:caseId/review')
export class ReviewController {
  constructor(private readonly service: ReviewService) {}

  @Get()
  findAll(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Post()
  create(@Param('caseId') _id: string, @Body() _dto: CreateReviewDto): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Get('feedback')
  getFeedback(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }
}
