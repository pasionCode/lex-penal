import { Injectable } from '@nestjs/common';
import { ClientsRepository } from './clients.repository';

/** Servicio de clients. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class ClientsService {
  constructor(private readonly repository: ClientsRepository) {}
}
