import { Body, Controller, Get, Param, Post, Put, Query } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { QueryUsersDto } from './dto/query-users.dto';
import { UpdateUserDto } from './dto/update-user.dto';

/**
 * GET    /api/v1/users
 * POST   /api/v1/users
 * GET    /api/v1/users/:id
 * PUT    /api/v1/users/:id
 * Acceso: solo Administrador (perfiles y activación).
 */
@Controller('api/v1/users')
export class UsersController {
  constructor(private readonly service: UsersService) {}

  @Get()
  findAll(@Query() _query: QueryUsersDto): Promise<unknown> { throw new Error('not implemented'); }

  @Post()
  create(@Body() _dto: CreateUserDto): Promise<unknown> { throw new Error('not implemented'); }

  @Get(':id')
  findOne(@Param('id') _id: string): Promise<unknown> { throw new Error('not implemented'); }

  @Put(':id')
  update(@Param('id') _id: string, @Body() _dto: UpdateUserDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
