import { Injectable } from '@nestjs/common';
import { CasesRepository } from './cases.repository';

/**
 * Orquesta CRUD del caso y delega transiciones a CasoEstadoService.
 * R08: al activar (borrador→en_analisis) crea estructura base atómica.
 * R09: cerrado es inmutable — verificar antes de delegar a herramientas.
 */
@Injectable()
export class CasesService {
  constructor(private readonly repository: CasesRepository) {}
}
