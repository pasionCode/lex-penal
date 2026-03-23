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
  NotImplementedException,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { QueryUsersDto } from './dto/query-users.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

/**
 * Controller de usuarios.
 *
 * Rutas:
 * GET    /users/me    - Perfil del usuario autenticado (US-05)
 * GET    /users       - Listar usuarios (solo admin) [stub]
 * POST   /users       - Crear usuario (solo admin) [stub]
 * GET    /users/:id   - Detalle de usuario (solo admin) [stub]
 * PUT    /users/:id   - Actualizar usuario (solo admin) [stub]
 */
@Controller('users')
export class UsersController {
  constructor(private readonly service: UsersService) {}

  /**
   * GET /api/v1/users/me
   * US-05: Consultar mi perfil.
   *
   * Retorna los datos del usuario autenticado.
   * Requiere token JWT válido.
   *
   * @param userId ID del usuario extraído del token
   * @returns Datos del usuario (id, nombre, email, perfil)
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

  /**
   * GET /api/v1/users
   * Listar usuarios con filtros.
   * Acceso: solo Administrador.
   * Estado: STUB - No implementado en Sprint 1.
   */
  @Get()
  findAll(@Query() _query: QueryUsersDto): Promise<unknown> {
    throw new NotImplementedException('Endpoint no implementado en Sprint 1');
  }

  /**
   * POST /api/v1/users
   * Crear usuario.
   * Acceso: solo Administrador.
   * Estado: STUB - No implementado en Sprint 1.
   */
  @Post()
  create(@Body() _dto: CreateUserDto): Promise<unknown> {
    throw new NotImplementedException('Endpoint no implementado en Sprint 1');
  }

  /**
   * GET /api/v1/users/:id
   * Detalle de un usuario.
   * Acceso: solo Administrador.
   * Estado: STUB - No implementado en Sprint 1.
   */
  @Get(':id')
  findOne(@Param('id') _id: string): Promise<unknown> {
    throw new NotImplementedException('Endpoint no implementado en Sprint 1');
  }

  /**
   * PUT /api/v1/users/:id
   * Actualizar usuario.
   * Acceso: solo Administrador.
   * Estado: STUB - No implementado en Sprint 1.
   */
  @Put(':id')
  update(@Param('id') _id: string, @Body() _dto: UpdateUserDto): Promise<unknown> {
    throw new NotImplementedException('Endpoint no implementado en Sprint 1');
  }
}
