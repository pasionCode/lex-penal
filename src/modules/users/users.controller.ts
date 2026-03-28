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
  ForbiddenException,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { QueryUsersDto } from './dto/query-users.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { PerfilUsuario } from '../../types/enums';

@Controller('users')
export class UsersController {
  constructor(private readonly service: UsersService) {}

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

  @Get()
  findAll(@Query() _query: QueryUsersDto): Promise<unknown> {
    throw new NotImplementedException('Endpoint no implementado en Sprint 1');
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  async create(
    @Body() dto: CreateUserDto,
    @CurrentUser('sub') currentUserId: string,
    @CurrentUser('perfil') perfil: string,
  ) {
    if (perfil !== PerfilUsuario.ADMINISTRADOR) {
      throw new ForbiddenException('Solo administradores pueden crear usuarios');
    }

    return this.service.createUser(dto, currentUserId);
  }

  @Get(':id')
  findOne(@Param('id') _id: string): Promise<unknown> {
    throw new NotImplementedException('Endpoint no implementado en Sprint 1');
  }

  @Put(':id')
  update(@Param('id') _id: string, @Body() _dto: UpdateUserDto): Promise<unknown> {
    throw new NotImplementedException('Endpoint no implementado en Sprint 1');
  }
}
