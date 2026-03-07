import { Injectable } from '@nestjs/common';
import { RisksRepository } from './risks.repository';

/** Servicio de risks. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class RisksService {
  constructor(private readonly repository: RisksRepository) {}
}
