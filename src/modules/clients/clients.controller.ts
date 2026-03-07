import { Body, Controller, Get, Param, Post, Put } from '@nestjs/common';
import { ClientsService } from './clients.service';
import { CreateClientDto } from './dto/create-client.dto';
import { UpdateClientDto } from './dto/update-client.dto';

/**
 * GET    /api/v1/clients
 * POST   /api/v1/clients
 * GET    /api/v1/clients/:id
 * PUT    /api/v1/clients/:id
 * UNIQUE: (tipo_documento, documento) — no duplicar procesados.
 */
@Controller('api/v1/clients')
export class ClientsController {
  constructor(private readonly service: ClientsService) {}

  @Get()
  findAll(): Promise<unknown> { throw new Error('not implemented'); }

  @Post()
  create(@Body() _dto: CreateClientDto): Promise<unknown> { throw new Error('not implemented'); }

  @Get(':id')
  findOne(@Param('id') _id: string): Promise<unknown> { throw new Error('not implemented'); }

  @Put(':id')
  update(@Param('id') _id: string, @Body() _dto: UpdateClientDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
