import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { UsersService } from './users.service';

/**
 * Servicio de bootstrap del módulo users.
 * Se ejecuta automáticamente al iniciar la aplicación.
 * Responsable de garantizar la existencia del usuario administrador base.
 * 
 * Configuración via variables de entorno:
 * - BOOTSTRAP_ADMIN_ENABLED: true/false
 * - BOOTSTRAP_ADMIN_NAME: nombre del administrador
 * - BOOTSTRAP_ADMIN_EMAIL: email del administrador
 * - BOOTSTRAP_ADMIN_PASSWORD: contraseña del administrador
 */
@Injectable()
export class BootstrapService implements OnModuleInit {
  private readonly logger = new Logger(BootstrapService.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly usersService: UsersService,
  ) {}

  /**
   * Ejecutado automáticamente por NestJS al inicializar el módulo.
   * Implementa el bootstrap idempotente del usuario administrador.
   */
  async onModuleInit(): Promise<void> {
    await this.runBootstrap();
  }

  /**
   * Ejecuta el proceso de bootstrap.
   * Separa la lógica para facilitar testing.
   */
  async runBootstrap(): Promise<void> {
    // Verificar si el bootstrap está habilitado
    const enabled = this.configService.get<string>('BOOTSTRAP_ADMIN_ENABLED');
    const isEnabled = enabled?.toLowerCase().trim() === 'true';
    if (!isEnabled) {
      this.logger.log('Bootstrap de administrador deshabilitado');
      return;
    }

    this.logger.log('Iniciando proceso de bootstrap de usuarios...');

    // Leer configuración
    const name = this.configService.get<string>('BOOTSTRAP_ADMIN_NAME');
    const email = this.configService.get<string>('BOOTSTRAP_ADMIN_EMAIL');
    const password = this.configService.get<string>('BOOTSTRAP_ADMIN_PASSWORD');

    // Validar configuración completa
    if (!name || !email || !password) {
      throw new Error(
        'BOOTSTRAP_ADMIN_NAME, BOOTSTRAP_ADMIN_EMAIL y BOOTSTRAP_ADMIN_PASSWORD son obligatorias cuando BOOTSTRAP_ADMIN_ENABLED=true',
      );
    }

    // Ejecutar bootstrap
    try {
      const result = await this.usersService.createBootstrapAdmin({
        nombre: name!,
        email: email!,
        password: password!,
      });

      switch (result.action) {
        case 'created':
          this.logger.log(`✅ ${result.message}`);
          break;
        case 'skipped_exists':
          this.logger.log(`⏭️ ${result.message}`);
          break;
        case 'skipped_admin_exists':
          this.logger.log(`⏭️ ${result.message}`);
          break;
        case 'error':
          throw new Error(result.message);
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Error desconocido';
      this.logger.error(`❌ Falló el bootstrap de administrador: ${errorMsg}`);
      throw error;
    }

    this.logger.log('Proceso de bootstrap de usuarios completado');
  }
}
