import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Put,
  Query,
  UseGuards,
  NotFoundException,
  ForbiddenException,
  ParseUUIDPipe,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { QueryUsersDto } from './dto/query-users.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { PerfilUsuario } from '../../types/enums';

/**
 * Controlador de usuarios.
 *
 * Endpoints:
 * - GET  /me         → Datos de sesión del usuario autenticado
 * - GET  /           → Lista usuarios (solo admin)
 * - POST /           → Crea usuario (solo admin)
 * - GET  /:id        → Detalle de usuario (solo admin)
 * - PUT  /:id        → Actualiza usuario (solo admin)
 *
 * E5-06: Cierre de superficie administrativa mínima.
 */
@Controller('users')
export class UsersController {
  constructor(private readonly service: UsersService) {}

  // ==========================================================================
  // ENDPOINT DE SESIÓN (existente)
  // ==========================================================================

  /**
   * Retorna datos del usuario autenticado.
   * Acceso: cualquier usuario autenticado.
   */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getMe(@CurrentUser('sub') userId: string) {
    const user = await this.service.getSessionData(userId);

    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    return {
      id: user.id,
      nombre: user.nombre,
      email: user.email,
      perfil: user.perfil,
    };
  }

  // ==========================================================================
  // ENDPOINTS ADMINISTRATIVOS (E5-06)
  // ==========================================================================

  /**
   * Lista todos los usuarios.
   * Acceso: solo administrador.
   * Respuesta saneada (sin password_hash).
   */
  @Get()
  @UseGuards(JwtAuthGuard)
  async findAll(
    @Query() _query: QueryUsersDto,
    @CurrentUser('perfil') perfil: string,
  ) {
    this.assertAdmin(perfil);
    return this.service.listUsers();
  }

  /**
   * Crea un nuevo usuario.
   * Acceso: solo administrador.
   */
  @Post()
  @UseGuards(JwtAuthGuard)
  async create(
    @Body() dto: CreateUserDto,
    @CurrentUser('sub') currentUserId: string,
    @CurrentUser('perfil') perfil: string,
  ) {
    this.assertAdmin(perfil);
    return this.service.createUser(dto, currentUserId);
  }

  /**
   * Obtiene detalle de un usuario por ID.
   * Acceso: solo administrador.
   * Respuesta saneada (sin password_hash).
   */
  @Get(':id')
  @UseGuards(JwtAuthGuard)
  async findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('perfil') perfil: string,
  ) {
    this.assertAdmin(perfil);
    return this.service.getUserByIdForAdmin(id);
  }

  /**
   * Actualiza un usuario.
   * Acceso: solo administrador.
   * Campos actualizables: nombre, email, perfil, activo.
   * Respuesta saneada (sin password_hash).
   */
  @Put(':id')
  @UseGuards(JwtAuthGuard)
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateUserDto,
    @CurrentUser('sub') currentUserId: string,
    @CurrentUser('perfil') perfil: string,
  ) {
    this.assertAdmin(perfil);
    return this.service.updateUser(id, dto, currentUserId);
  }

  // ==========================================================================
  // UTILIDADES PRIVADAS
  // ==========================================================================

  /**
   * Verifica que el perfil sea administrador.
   * @throws ForbiddenException si no es administrador
   */
  private assertAdmin(perfil: string): void {
    if (perfil !== PerfilUsuario.ADMINISTRADOR) {
      throw new ForbiddenException('Solo administradores pueden realizar esta acción');
    }
  }
}
