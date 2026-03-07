import { Injectable } from '@nestjs/common';
import { ClientBriefingRepository } from './client-briefing.repository';

/** Servicio de client-briefing. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class ClientBriefingService {
  constructor(private readonly repository: ClientBriefingRepository) {}
}
