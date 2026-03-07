import { Injectable } from '@nestjs/common';
import { FactsRepository } from './facts.repository';

/** Servicio de facts. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class FactsService {
  constructor(private readonly repository: FactsRepository) {}
}
