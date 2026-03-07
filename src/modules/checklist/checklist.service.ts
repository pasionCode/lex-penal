import { Injectable } from '@nestjs/common';
import { ChecklistRepository } from './checklist.repository';

/** Servicio de checklist. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class ChecklistService {
  constructor(private readonly repository: ChecklistRepository) {}
}
