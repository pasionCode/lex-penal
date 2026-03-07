import { Injectable } from '@nestjs/common';
import { ReviewRepository } from './review.repository';

/** Servicio de review. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class ReviewService {
  constructor(private readonly repository: ReviewRepository) {}
}
