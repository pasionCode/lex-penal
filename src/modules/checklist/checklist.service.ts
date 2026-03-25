import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { ChecklistRepository, BloqueConItems } from './checklist.repository';
import { UpdateChecklistDto } from './dto/update-checklist-item.dto';
import { PerfilUsuario } from '../../types/enums';

@Injectable()
export class ChecklistService {
  constructor(private readonly repository: ChecklistRepository) {}

  async findByCaseId(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<{ bloques: BloqueConItems[] }> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const bloques = await this.repository.findByCaseId(casoId);

    return { bloques };
  }

  async updateItems(
    casoId: string,
    dto: UpdateChecklistDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<{ bloques: BloqueConItems[] }> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const bloquesAfectados = new Set<string>();

    for (const itemUpdate of dto.items) {
      const item = await this.repository.findItemById(itemUpdate.id);

      if (!item) {
        throw new BadRequestException(`Item ${itemUpdate.id} no encontrado`);
      }

      if (item.caso_id !== casoId) {
        throw new ForbiddenException(`Item ${itemUpdate.id} no pertenece a este caso`);
      }

      await this.repository.updateItem(itemUpdate.id, itemUpdate.marcado, userId);
      bloquesAfectados.add(item.bloque_id);
    }

    for (const bloqueId of bloquesAfectados) {
      await this.repository.updateBloqueCompletado(bloqueId);
    }

    const bloques = await this.repository.findByCaseId(casoId);
    return { bloques };
  }

  async bootstrapIfNeeded(casoId: string): Promise<void> {
    const exists = await this.repository.hasChecklist(casoId);
    if (!exists) {
      await this.repository.createBaseStructure(casoId);
    }
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