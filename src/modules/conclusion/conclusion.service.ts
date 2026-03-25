import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { ConclusionOperativa } from '@prisma/client';
import { ConclusionRepository } from './conclusion.repository';
import { UpdateConclusionDto } from './dto/update-conclusion.dto';
import { PerfilUsuario } from '../../types/enums';

@Injectable()
export class ConclusionService {
  constructor(private readonly repository: ConclusionRepository) {}

  async findByCaseId(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<ConclusionOperativa> {
    await this.checkCaseAccess(casoId, userId, perfil);

    let conclusion = await this.repository.findByCaseId(casoId);

    if (!conclusion) {
      conclusion = await this.repository.create({
        caso_id: casoId,
        creado_por: userId,
      });
    }

    return conclusion;
  }

  async update(
    casoId: string,
    dto: UpdateConclusionDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<ConclusionOperativa> {
    await this.checkCaseAccess(casoId, userId, perfil);

    let conclusion = await this.repository.findByCaseId(casoId);

    if (!conclusion) {
      return this.repository.create({
        caso_id: casoId,
        ...this.dtoToData(dto),
        creado_por: userId,
        actualizado_por: userId,
      });
    }

    const updateData: Record<string, unknown> = {
      actualizado_por: userId,
    };

    // Solo actualizar campos enviados
    Object.entries(dto).forEach(([key, value]) => {
      if (value !== undefined) {
        updateData[key] = value;
      }
    });

    return this.repository.update(casoId, updateData);
  }

  private dtoToData(dto: UpdateConclusionDto): Record<string, unknown> {
    const data: Record<string, unknown> = {};
    Object.entries(dto).forEach(([key, value]) => {
      data[key] = value ?? null;
    });
    return data;
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
