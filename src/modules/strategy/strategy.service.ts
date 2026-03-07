import { Injectable } from '@nestjs/common';
import { StrategyRepository } from './strategy.repository';

/** Servicio de strategy. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class StrategyService {
  constructor(private readonly repository: StrategyRepository) {}
}
