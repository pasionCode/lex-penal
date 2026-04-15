import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { ConclusionOperativa } from '@prisma/client';
import { ConclusionRepository } from './conclusion.repository';
import { UpdateConclusionDto } from './dto/update-conclusion.dto';
import { PerfilUsuario, EstadoCaso } from '../../types/enums';

const ESTADOS_ESCRITURA_PERMITIDA_CONCLUSION: EstadoCaso[] = [
  EstadoCaso.EN_ANALISIS,
  EstadoCaso.DEVUELTO,
  EstadoCaso.LISTO_PARA_CLIENTE,
];

@Injectable()
export class ConclusionService {
  constructor(private readonly repository: ConclusionRepository) {}

  /**
   * Obtiene la conclusión operativa del caso.
   * Si no existe, solo la auto-crea cuando el estado permite escritura.
   */
  async findByCaseId(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<ConclusionOperativa> {
    await this.checkCaseAccess(casoId, userId, perfil);

    let conclusion = await this.repository.findByCaseId(casoId);

    if (!conclusion) {
      await this.checkWritePermission(casoId);

      conclusion = await this.repository.create({
        caso_id: casoId,
        creado_por: userId,
      });
    }

    return conclusion;
  }

  /**
   * Actualiza la conclusión operativa del caso.
   * Si no existe, la crea primero.
   * Solo permitido en estados con escritura habilitada.
   */
  async update(
    casoId: string,
    dto: UpdateConclusionDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<ConclusionOperativa> {
    await this.checkCaseAccess(casoId, userId, perfil);
    await this.checkWritePermission(casoId);

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
      if (responsable != userId) {
        throw new ForbiddenException('Sin acceso a este caso');
      }
    }
  }

  /**
   * Valida que el estado del caso permita escritura en conclusion.
   * Política: permite en_analisis, devuelto y listo_para_cliente.
   */
  private async checkWritePermission(casoId: string): Promise<void> {
    const estado = await this.repository.getCaseState(casoId);

    if (!estado || !ESTADOS_ESCRITURA_PERMITIDA_CONCLUSION.includes(estado as EstadoCaso)) {
      throw new ConflictException(
        `No se permite modificar conclusion en estado ${estado ?? 'desconocido'}`,
      );
    }
  }
}
