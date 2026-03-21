import { Injectable } from '@nestjs/common';
import { Usuario, Prisma, PerfilUsuario } from '@prisma/client';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';

/**
 * Repositorio de users.
 * Único punto de acceso a la persistencia del módulo.
 * Depende de PrismaService (ADR-006).
 */
@Injectable()
export class UsersRepository {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Busca usuario por email.
   * @param email Email del usuario (ya normalizado)
   * @returns Usuario o null si no existe
   */
  async findByEmail(email: string): Promise<Usuario | null> {
    return this.prisma.usuario.findUnique({
      where: { email },
    });
  }

  /**
   * Busca usuario por ID.
   * @param id UUID del usuario
   * @returns Usuario o null si no existe
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
}
