import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { LineaTiempo } from '@prisma/client';
import { TimelineRepository } from './timeline.repository';
import { CreateTimelineEntryDto } from './dto/create-timeline-entry.dto';
import { PerfilUsuario } from '../../types/enums';

@Injectable()
export class TimelineService {
  constructor(private readonly repository: TimelineRepository) {}

  async create(
    casoId: string,
    dto: CreateTimelineEntryDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<LineaTiempo> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const orden = await this.repository.getNextOrder(casoId);

    return this.repository.create({
      caso_id: casoId,
      fecha_evento: new Date(dto.fecha_evento),
      descripcion: dto.descripcion,
      orden,
      creado_por: userId,
    });
  }

  async findByCaseId(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<LineaTiempo[]> {
    await this.checkCaseAccess(casoId, userId, perfil);
    return this.repository.findByCaseId(casoId);
  }

  private async checkCaseAccess(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<void> {
    const exists = await this.repository.caseExists(casoId);
    if (!exists) {
      throw new NotFoundException(`Caso ${casoId} no encontrado`);
    }

    if (perfil === PerfilUsuario.ESTUDIANTE) {
      const responsable = await this.repository.getCaseResponsable(casoId);
      if (responsable !== userId) {
        throw new ForbiddenException('Sin acceso a este caso');
      }
    }
  }
}
