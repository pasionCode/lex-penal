import { Injectable } from '@nestjs/common';
import { ReportsRepository } from './reports.repository';

/** Servicio de reports. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class ReportsService {
  constructor(private readonly repository: ReportsRepository) {}
}
