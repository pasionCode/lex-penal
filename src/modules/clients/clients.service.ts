import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { Cliente } from '@prisma/client';
import { ClientsRepository } from './clients.repository';
import { CreateClientDto } from './dto/create-client.dto';
import { UpdateClientDto } from './dto/update-client.dto';
import { SituacionLibertad } from '../../types/enums';

@Injectable()
export class ClientsService {
  constructor(private readonly repository: ClientsRepository) {}

  async findAll(): Promise<Cliente[]> {
    return this.repository.findAll();
  }

  async findOne(id: string): Promise<Cliente> {
    const client = await this.repository.findById(id);
    if (!client) {
      throw new NotFoundException(`Cliente ${id} no encontrado`);
    }
    return client;
  }

  async create(dto: CreateClientDto, userId: string): Promise<Cliente> {
    // Verificar unicidad (tipo_documento, documento)
    const exists = await this.repository.findByDocument(
      dto.tipo_documento,
      dto.documento,
    );
    if (exists) {
      throw new ConflictException(
        'Ya existe un cliente con ese tipo y número de documento',
      );
    }

    // Si libre, lugar_detencion queda null
    const lugarDetencion =
      dto.situacion_libertad === SituacionLibertad.LIBRE
        ? null
        : dto.lugar_detencion ?? null;

    return this.repository.create({
      nombre: dto.nombre,
      tipo_documento: dto.tipo_documento,
      documento: dto.documento,
      contacto: dto.contacto ?? null,
      situacion_libertad: dto.situacion_libertad,
      lugar_detencion: lugarDetencion,
      creado_por: userId,
    });
  }

  async update(
    id: string,
    dto: UpdateClientDto,
    userId: string,
  ): Promise<Cliente> {
    const client = await this.repository.findById(id);
    if (!client) {
      throw new NotFoundException(`Cliente ${id} no encontrado`);
    }

    // Verificar unicidad si cambia documento
    if (dto.tipo_documento !== undefined || dto.documento !== undefined) {
      const newTipo = dto.tipo_documento ?? client.tipo_documento;
      const newDoc = dto.documento ?? client.documento;
      const exists = await this.repository.findByDocument(newTipo, newDoc);
      if (exists && exists.id !== id) {
        throw new ConflictException(
          'Ya existe un cliente con ese tipo y número de documento',
        );
      }
    }

    // Calcular estado resultante de situacion_libertad
    const situacionResultante =
      dto.situacion_libertad ?? (client.situacion_libertad as SituacionLibertad);

    // Calcular lugar_detencion resultante
    let lugarDetencionResultante: string | null;

    if (situacionResultante === SituacionLibertad.LIBRE) {
      // Si resultante es libre, lugar_detencion debe ser null
      lugarDetencionResultante = null;
    } else {
      // Si resultante es detenido, necesita lugar_detencion
      lugarDetencionResultante =
        dto.lugar_detencion !== undefined
          ? dto.lugar_detencion
          : client.lugar_detencion;

      if (!lugarDetencionResultante) {
        throw new BadRequestException(
          'lugar_detencion es requerido si situacion_libertad es detenido',
        );
      }
    }

    const updateData: Record<string, unknown> = {
      actualizado_por: userId,
    };

    if (dto.nombre !== undefined) updateData.nombre = dto.nombre;
    if (dto.tipo_documento !== undefined)
      updateData.tipo_documento = dto.tipo_documento;
    if (dto.documento !== undefined) updateData.documento = dto.documento;
    if (dto.contacto !== undefined) updateData.contacto = dto.contacto;
    if (dto.situacion_libertad !== undefined)
      updateData.situacion_libertad = dto.situacion_libertad;

    // Siempre actualizar lugar_detencion al valor resultante calculado
    updateData.lugar_detencion = lugarDetencionResultante;

    return this.repository.update(id, updateData);
  }
}
