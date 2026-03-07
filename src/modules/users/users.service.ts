import { Injectable } from '@nestjs/common';
import { UsersRepository } from './users.repository';

/** Servicio de users. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class UsersService {
  constructor(private readonly repository: UsersRepository) {}
}
