import { Injectable } from '@nestjs/common';
import { Usuario, Prisma, PerfilUsuario } from '@prisma/client';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';

/**
 * Tipo de respuesta saneada para administración.
 * Nunca incluye password_hash.
 */
export interface UsuarioSaneado {
  id: string;
  nombre: string;
  email: string;
  perfil: string;
  activo: boolean;
  creado_en: Date;
}

/**
 * Select explícito para respuestas saneadas.
 * Garantiza que password_hash nunca llega a memoria.
 */
const SELECT_SANEADO = {
  id: true,
  nombre: true,
  email: true,
  perfil: true,
  activo: true,
  creado_en: true,
} as const;

/**
 * Repositorio de users.
 * Único punto de acceso a la persistencia del módulo.
 * Depende de PrismaService (ADR-006).
 */
@Injectable()
export class UsersRepository {
  constructor(private readonly prisma: PrismaService) {}

  // ==========================================================================
  // MÉTODOS EXISTENTES (no modificar)
  // ==========================================================================

  /**
   * Busca usuario por email.
   * @param email Email del usuario (ya normalizado)
   * @returns Usuario completo o null si no existe
   */
  async findByEmail(email: string): Promise<Usuario | null> {
    return this.prisma.usuario.findUnique({
      where: { email },
    });
  }

  /**
   * Busca usuario por ID.
   * @param id UUID del usuario
   * @returns Usuario completo o null si no existe
   */
  async findById(id: string): Promise<Usuario | null> {
    return this.prisma.usuario.findUnique({
      where: { id },
    });
  }

  /**
   * Verifica si existe al menos un usuario con perfil administrador activo.
   * @returns true si existe al menos un administrador
   */
  async existsAdmin(): Promise<boolean> {
    const count = await this.prisma.usuario.count({
      where: {
        perfil: PerfilUsuario.administrador,
        activo: true,
      },
    });
    return count > 0;
  }

  /**
   * Crea un usuario en la base de datos.
   * @param data Datos del usuario (password ya hasheado como password_hash)
   * @returns Usuario creado
   */
  async create(data: Prisma.UsuarioCreateInput): Promise<Usuario> {
    return this.prisma.usuario.create({ data });
  }

  /**
   * Busca usuario por ID, solo campos para sesión.
   * @param id UUID del usuario
   * @returns Datos de sesión o null
   */
  async findForSession(
    id: string,
  ): Promise<Pick<Usuario, 'id' | 'nombre' | 'email' | 'perfil' | 'activo'> | null> {
    return this.prisma.usuario.findUnique({
      where: { id },
      select: {
        id: true,
        nombre: true,
        email: true,
        perfil: true,
        activo: true,
      },
    });
  }

  // ==========================================================================
  // MÉTODOS E5-06: Administración de usuarios
  // ==========================================================================

  /**
   * Lista todos los usuarios con respuesta saneada.
   * Para uso administrativo.
   * @returns Lista de usuarios sin password_hash
   */
  async findManyForAdmin(): Promise<UsuarioSaneado[]> {
    return this.prisma.usuario.findMany({
      select: SELECT_SANEADO,
      orderBy: { creado_en: 'desc' },
    });
  }

  /**
   * Busca usuario por ID con respuesta saneada.
   * Para uso administrativo.
   * @param id UUID del usuario
   * @returns Usuario saneado o null si no existe
   */
  async findByIdForAdmin(id: string): Promise<UsuarioSaneado | null> {
    return this.prisma.usuario.findUnique({
      where: { id },
      select: SELECT_SANEADO,
    });
  }

  /**
   * Verifica si un email existe excluyendo un usuario específico.
   * Para validar duplicados en actualización.
   * @param email Email a verificar (ya normalizado)
   * @param excludeUserId ID del usuario a excluir de la búsqueda
   * @returns true si el email existe en otro usuario
   */
  async emailExistsExcluding(email: string, excludeUserId: string): Promise<boolean> {
    const existing = await this.prisma.usuario.findFirst({
      where: {
        email,
        id: { not: excludeUserId },
      },
      select: { id: true },
    });
    return existing !== null;
  }

  /**
   * Actualiza un usuario y retorna respuesta saneada.
   * @param id UUID del usuario
   * @param data Datos a actualizar
   * @returns Usuario actualizado (saneado)
   */
  async update(
    id: string,
    data: Prisma.UsuarioUpdateInput,
  ): Promise<UsuarioSaneado> {
    return this.prisma.usuario.update({
      where: { id },
      data,
      select: SELECT_SANEADO,
    });
  }
}
