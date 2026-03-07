import { Injectable } from '@nestjs/common';
import { AuditRepository } from './audit.repository';

/** Servicio de audit. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class AuditService {
  constructor(private readonly repository: AuditRepository) {}
}
