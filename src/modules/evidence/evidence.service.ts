import { Injectable } from '@nestjs/common';
import { EvidenceRepository } from './evidence.repository';

/** Servicio de evidence. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class EvidenceService {
  constructor(private readonly repository: EvidenceRepository) {}
}
