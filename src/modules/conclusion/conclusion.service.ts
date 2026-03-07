import { Injectable } from '@nestjs/common';
import { ConclusionRepository } from './conclusion.repository';

/** Servicio de conclusion. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class ConclusionService {
  constructor(private readonly repository: ConclusionRepository) {}
}
