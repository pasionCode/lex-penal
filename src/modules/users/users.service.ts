import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Usuario, PerfilUsuario as PrismaPerfilUsuario, Prisma } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import { UsersRepository, UsuarioSaneado } from './users.repository';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { PerfilUsuario } from '../../types/enums';

export interface BootstrapUserData {
  nombre: string;
  email: string;
  password: string;
}

export interface BootstrapResult {
  action: 'created' | 'skipped_exists' | 'skipped_admin_exists' | 'error';
  message: string;
  userId?: string;
}

@Injectable()
export class UsersService {
  private readonly SALT_ROUNDS = 10;

  constructor(private readonly repository: UsersRepository) {}

  // ==========================================================================
  // UTILIDADES
  // ==========================================================================

  normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
  }

  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, this.SALT_ROUNDS);
  }

  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  /**
   * Convierte perfil de dominio a Prisma.
   * Punto único de traducción de enum.
   */
  private toPrismaPerfil(perfil: PerfilUsuario): PrismaPerfilUsuario {
    const map: Record<PerfilUsuario, PrismaPerfilUsuario> = {
      [PerfilUsuario.ESTUDIANTE]: PrismaPerfilUsuario.estudiante,
      [PerfilUsuario.SUPERVISOR]: PrismaPerfilUsuario.supervisor,
      [PerfilUsuario.ADMINISTRADOR]: PrismaPerfilUsuario.administrador,
    };
    return map[perfil];
  }

  // ==========================================================================
  // MÉTODOS EXISTENTES (no modificar interfaz pública)
  // ==========================================================================

  async findByEmail(email: string): Promise<Usuario | null> {
    const normalizedEmail = this.normalizeEmail(email);
    return this.repository.findByEmail(normalizedEmail);
  }

  async findById(id: string): Promise<Usuario | null> {
    return this.repository.findById(id);
  }

  async getSessionData(
    id: string,
  ): Promise<Pick<Usuario, 'id' | 'nombre' | 'email' | 'perfil' | 'activo'> | null> {
    return this.repository.findForSession(id);
  }

  async createUser(
    dto: CreateUserDto,
    currentUserId: string,
  ): Promise<Pick<Usuario, 'id' | 'nombre' | 'email' | 'perfil' | 'activo'>> {
    if (!currentUserId) {
      throw new BadRequestException('Usuario creador es obligatorio');
    }

    const normalizedEmail = this.normalizeEmail(dto.email);
    const existingUser = await this.repository.findByEmail(normalizedEmail);

    if (existingUser) {
      throw new ConflictException(`Ya existe un usuario con email ${normalizedEmail}`);
    }

    const passwordHash = await this.hashPassword(dto.password);

    const usuario = await this.repository.create({
      nombre: dto.nombre.trim(),
      email: normalizedEmail,
      password_hash: passwordHash,
      perfil: dto.perfil as unknown as PrismaPerfilUsuario,
      activo: dto.activo ?? true,
      creador: {
        connect: { id: currentUserId },
      },
    });

    return {
      id: usuario.id,
      nombre: usuario.nombre,
      email: usuario.email,
      perfil: usuario.perfil,
      activo: usuario.activo,
    };
  }

  async createBootstrapAdmin(data: BootstrapUserData): Promise<BootstrapResult> {
    if (!data.nombre || data.nombre.trim() === '') {
      return { action: 'error', message: 'Nombre es obligatorio' };
    }
    if (!data.email || data.email.trim() === '') {
      return { action: 'error', message: 'Email es obligatorio' };
    }
    if (!data.password || data.password.trim() === '') {
      return { action: 'error', message: 'Password es obligatorio' };
    }

    const MIN_PASSWORD_LENGTH = 8;
    if (data.password.length < MIN_PASSWORD_LENGTH) {
      return {
        action: 'error',
        message: `Password debe tener al menos ${MIN_PASSWORD_LENGTH} caracteres`,
      };
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const normalizedEmail = this.normalizeEmail(data.email);
    if (!emailRegex.test(normalizedEmail)) {
      return { action: 'error', message: 'Formato de email inválido' };
    }

    const existingUser = await this.findByEmail(data.email);
    if (existingUser) {
      if (existingUser.perfil === PrismaPerfilUsuario.administrador) {
        return {
          action: 'skipped_exists',
          message: `Usuario bootstrap ya existe: ${normalizedEmail}`,
          userId: existingUser.id,
        };
      }

      return {
        action: 'error',
        message: `Inconsistencia crítica: email ${normalizedEmail} existe con perfil ${existingUser.perfil}, se esperaba administrador`,
      };
    }

    const adminExists = await this.repository.existsAdmin();
    if (adminExists) {
      return {
        action: 'skipped_admin_exists',
        message: 'Ya existe al menos un administrador en el sistema',
      };
    }

    const passwordHash = await this.hashPassword(data.password);

    const usuario = await this.repository.create({
      nombre: data.nombre.trim(),
      email: normalizedEmail,
      password_hash: passwordHash,
      perfil: PrismaPerfilUsuario.administrador,
      activo: true,
    });

    return {
      action: 'created',
      message: `Usuario bootstrap administrador creado: ${normalizedEmail}`,
      userId: usuario.id,
    };
  }

  // ==========================================================================
  // MÉTODOS E5-06: Administración de usuarios
  // ==========================================================================

  /**
   * Lista todos los usuarios para administración.
   * Retorna respuesta saneada (sin password_hash).
   */
  async listUsers(): Promise<UsuarioSaneado[]> {
    return this.repository.findManyForAdmin();
  }

  /**
   * Obtiene un usuario por ID para administración.
   * @throws NotFoundException si el usuario no existe
   */
  async getUserByIdForAdmin(id: string): Promise<UsuarioSaneado> {
    const usuario = await this.repository.findByIdForAdmin(id);

    if (!usuario) {
      throw new NotFoundException(`Usuario ${id} no encontrado`);
    }

    return usuario;
  }

  /**
   * Actualiza un usuario.
   * @param id ID del usuario a actualizar
   * @param dto Datos a actualizar
   * @param _currentUserId ID del usuario que realiza la acción (para auditoría futura)
   * @throws NotFoundException si el usuario no existe
   * @throws ConflictException si el email ya existe en otro usuario
   */
  async updateUser(
    id: string,
    dto: UpdateUserDto,
    _currentUserId: string,
  ): Promise<UsuarioSaneado> {
    // 1. Verificar que el usuario existe
    const existingUser = await this.repository.findByIdForAdmin(id);
    if (!existingUser) {
      throw new NotFoundException(`Usuario ${id} no encontrado`);
    }

    // 2. Si se actualiza email, verificar duplicado
    if (dto.email !== undefined) {
      const normalizedEmail = this.normalizeEmail(dto.email);
      const emailExists = await this.repository.emailExistsExcluding(
        normalizedEmail,
        id,
      );

      if (emailExists) {
        throw new ConflictException(
          `Ya existe un usuario con email ${normalizedEmail}`,
        );
      }
    }

    // 3. Construir datos de actualización
    const updateData: Prisma.UsuarioUpdateInput = {};

    if (dto.nombre !== undefined) {
      updateData.nombre = dto.nombre.trim();
    }

    if (dto.email !== undefined) {
      updateData.email = this.normalizeEmail(dto.email);
    }

    if (dto.perfil !== undefined) {
      updateData.perfil = this.toPrismaPerfil(dto.perfil);
    }

    if (dto.activo !== undefined) {
      updateData.activo = dto.activo;
    }

    // 4. Si no hay campos a actualizar, retornar usuario actual
    if (Object.keys(updateData).length === 0) {
      return existingUser;
    }

    // 5. Actualizar y retornar
    return this.repository.update(id, updateData);
  }
}
