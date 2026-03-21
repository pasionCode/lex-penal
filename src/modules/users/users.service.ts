import { Injectable } from '@nestjs/common';
import { Usuario, PerfilUsuario } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import { UsersRepository } from './users.repository';

/**
 * Datos requeridos para crear un usuario via bootstrap.
 * No usa CreateUserDto porque el bootstrap tiene reglas distintas.
 */
export interface BootstrapUserData {
  nombre: string;
  email: string;
  password: string;
}

/**
 * Resultado de la operación de bootstrap.
 */
export interface BootstrapResult {
  action: 'created' | 'skipped_exists' | 'skipped_admin_exists' | 'error';
  message: string;
  userId?: string;
}

/**
 * Servicio de users.
 * Orquesta la lógica de negocio del módulo.
 */
@Injectable()
export class UsersService {
  private readonly SALT_ROUNDS = 10;

  constructor(private readonly repository: UsersRepository) {}

  /**
   * Normaliza un email: trim + lowercase.
   * @param email Email a normalizar
   * @returns Email normalizado
   */
  normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
  }

  /**
   * Hashea una contraseña usando bcrypt.
   * @param password Contraseña en texto plano
   * @returns Hash de la contraseña
   */
  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, this.SALT_ROUNDS);
  }

  /**
   * Verifica una contraseña contra su hash.
   * @param password Contraseña en texto plano
   * @param hash Hash almacenado
   * @returns true si coincide
   */
  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  /**
   * Busca un usuario por email.
   * @param email Email a buscar (se normaliza internamente)
   * @returns Usuario o null
   */
  async findByEmail(email: string): Promise<Usuario | null> {
    const normalizedEmail = this.normalizeEmail(email);
    return this.repository.findByEmail(normalizedEmail);
  }

  /**
   * Busca un usuario por ID.
   * @param id UUID del usuario
   * @returns Usuario o null
   */
  async findById(id: string): Promise<Usuario | null> {
    return this.repository.findById(id);
  }

  /**
   * Obtiene datos de sesión de un usuario.
   * @param id UUID del usuario
   * @returns Datos de sesión o null
   */
  async getSessionData(
    id: string,
  ): Promise<Pick<Usuario, 'id' | 'nombre' | 'email' | 'perfil' | 'activo'> | null> {
    return this.repository.findForSession(id);
  }

  /**
   * Crea el usuario administrador de bootstrap.
   * Implementa la lógica idempotente de US-04.
   * 
   * Escenarios:
   * A) Email ya existe con perfil administrador → skipped_exists
   * B) Email ya existe con otro perfil → error (inconsistencia)
   * C) No existe el email pero ya hay otro admin → skipped_admin_exists
   * D) No existe ningún admin → created
   * 
   * @param data Datos del usuario bootstrap
   * @returns Resultado de la operación
   */
  async createBootstrapAdmin(data: BootstrapUserData): Promise<BootstrapResult> {
    // Validaciones básicas
    if (!data.nombre || data.nombre.trim() === '') {
      return { action: 'error', message: 'Nombre es obligatorio' };
    }
    if (!data.email || data.email.trim() === '') {
      return { action: 'error', message: 'Email es obligatorio' };
    }
    if (!data.password || data.password.trim() === '') {
      return { action: 'error', message: 'Password es obligatorio' };
    }

    // Validación de longitud mínima de contraseña
    const MIN_PASSWORD_LENGTH = 8;
    if (data.password.length < MIN_PASSWORD_LENGTH) {
      return { 
        action: 'error', 
        message: `Password debe tener al menos ${MIN_PASSWORD_LENGTH} caracteres` 
      };
    }

    // Validación básica de formato de email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const normalizedEmail = this.normalizeEmail(data.email);
    if (!emailRegex.test(normalizedEmail)) {
      return { action: 'error', message: 'Formato de email inválido' };
    }

    // Escenario A/B: Verificar si el email ya existe
    const existingUser = await this.findByEmail(data.email);
    if (existingUser) {
      if (existingUser.perfil === PerfilUsuario.administrador) {
        // Escenario A: Ya existe con perfil admin
        return {
          action: 'skipped_exists',
          message: `Usuario bootstrap ya existe: ${normalizedEmail}`,
          userId: existingUser.id,
        };
      } else {
        // Escenario B: Existe pero con otro perfil - inconsistencia crítica
        return {
          action: 'error',
          message: `Inconsistencia crítica: email ${normalizedEmail} existe con perfil ${existingUser.perfil}, se esperaba administrador`,
        };
      }
    }

    // Escenario C: Verificar si ya existe algún administrador
    const adminExists = await this.repository.existsAdmin();
    if (adminExists) {
      return {
        action: 'skipped_admin_exists',
        message: 'Ya existe al menos un administrador en el sistema',
      };
    }

    // Escenario D: Crear el primer administrador
    const passwordHash = await this.hashPassword(data.password);

    const usuario = await this.repository.create({
      nombre: data.nombre.trim(),
      email: normalizedEmail,
      password_hash: passwordHash,
      perfil: PerfilUsuario.administrador,
      activo: true,
      // creado_por queda null para el primer usuario del sistema
    });

    return {
      action: 'created',
      message: `Usuario bootstrap administrador creado: ${normalizedEmail}`,
      userId: usuario.id,
    };
  }
}
