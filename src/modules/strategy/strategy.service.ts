import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { Estrategia } from '@prisma/client';
import { StrategyRepository } from './strategy.repository';
import { UpdateStrategyDto } from './dto/update-strategy.dto';
import { PerfilUsuario, EstadoCaso } from '../../types/enums';

@Injectable()
export class StrategyService {
  constructor(private readonly repository: StrategyRepository) {}

  private readonly estadosConEscritura = [
    EstadoCaso.EN_ANALISIS,
    EstadoCaso.DEVUELTO,
    EstadoCaso.LISTO_PARA_CLIENTE,
  ];

  /**
   * Obtiene la estrategia del caso.
   * Si no existe, la crea vacía solo cuando el estado permite escritura.
   */
  async findByCaseId(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Estrategia> {
    await this.checkCaseAccess(casoId, userId, perfil);

    let estrategia = await this.repository.findByCaseId(casoId);
    if (estrategia) {
      return estrategia;
    }

    const estado = await this.repository.getCaseState(casoId);
    if (!this.estadosConEscritura.includes(estado as EstadoCaso)) {
      throw new ConflictException(
        `El caso en estado "${estado}" no permite autocreación de estrategia.`,
      );
    }

    return this.repository.create({
      caso_id: casoId,
      creado_por: userId,
    });
  }

  /**
   * Actualiza la estrategia del caso.
   * Si no existe, la crea primero.
   * Solo permitido en estados con escritura habilitada.
   */
  async update(
    casoId: string,
    dto: UpdateStrategyDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Estrategia> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const estado = await this.repository.getCaseState(casoId);
    if (!this.estadosConEscritura.includes(estado as EstadoCaso)) {
      throw new ConflictException(
        `El caso en estado "${estado}" no permite modificar estrategia.`,
      );
    }

    let estrategia = await this.repository.findByCaseId(casoId);

    if (!estrategia) {
      return this.repository.create({
        caso_id: casoId,
        linea_principal: dto.linea_principal ?? null,
        fundamento_juridico: dto.fundamento_juridico ?? null,
        fundamento_probatorio: dto.fundamento_probatorio ?? null,
        linea_subsidiaria: dto.linea_subsidiaria ?? null,
        posicion_allanamiento: dto.posicion_allanamiento ?? null,
        posicion_preacuerdo: dto.posicion_preacuerdo ?? null,
        posicion_juicio: dto.posicion_juicio ?? null,
        creado_por: userId,
        actualizado_por: userId,
      });
    }

    const updateData: Record<string, unknown> = {
      actualizado_por: userId,
    };

    if (dto.linea_principal !== undefined) updateData.linea_principal = dto.linea_principal;
    if (dto.fundamento_juridico !== undefined) updateData.fundamento_juridico = dto.fundamento_juridico;
    if (dto.fundamento_probatorio !== undefined) updateData.fundamento_probatorio = dto.fundamento_probatorio;
    if (dto.linea_subsidiaria !== undefined) updateData.linea_subsidiaria = dto.linea_subsidiaria;
    if (dto.posicion_allanamiento !== undefined) updateData.posicion_allanamiento = dto.posicion_allanamiento;
    if (dto.posicion_preacuerdo !== undefined) updateData.posicion_preacuerdo = dto.posicion_preacuerdo;
    if (dto.posicion_juicio !== undefined) updateData.posicion_juicio = dto.posicion_juicio;

    return this.repository.update(casoId, updateData);
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
