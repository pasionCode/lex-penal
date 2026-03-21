import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { UsersRepository } from './users.repository';
import { BootstrapService } from './bootstrap.service';
import { PrismaModule } from '../../infrastructure/database/prisma/prisma.module';

/**
 * Módulo de gestión de usuarios.
 * 
 * Provee:
 * - UsersService: lógica de negocio de usuarios
 * - UsersRepository: acceso a persistencia
 * - BootstrapService: bootstrap automático del administrador
 * 
 * Exporta UsersService para uso desde AuthModule.
 */
@Module({
  imports: [PrismaModule],
  controllers: [UsersController],
  providers: [
    UsersService,
    UsersRepository,
    BootstrapService,
  ],
  exports: [UsersService],
})
export class UsersModule {}
