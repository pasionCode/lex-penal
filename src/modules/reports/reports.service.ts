import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InformeGenerado } from '@prisma/client';
import { ReportsRepository } from './reports.repository';
import { GenerateReportDto } from './dto/generate-report.dto';
import { PerfilUsuario } from '../../types/enums';

@Injectable()
export class ReportsService {
  constructor(private readonly repository: ReportsRepository) {}

  async findAll(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<InformeGenerado[]> {
    await this.checkCaseAccess(casoId, userId, perfil);
    return this.repository.findByCaseId(casoId);
  }

  /**
   * Genera un nuevo informe.
   * E6-02: Usa transacción atómica que incluye evento de auditoría.
   * Solo se registra evento en creación real (no en retorno idempotente).
   */
  async generate(
    casoId: string,
    dto: GenerateReportDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<InformeGenerado> {
    await this.checkCaseAccess(casoId, userId, perfil);

    // Idempotencia: si existe uno reciente (<5 min), retornar ese
    // NO registrar evento de auditoría en este caso
    const recent = await this.repository.findRecent(casoId, dto.tipo, dto.formato, 5);
    if (recent) {
      return recent;
    }

    // Obtener estado del caso para registrar
    const estado = await this.repository.getCaseState(casoId);

    // Generar ruta de archivo (MVP: placeholder)
    const filename = `${dto.tipo}_${casoId.slice(0, 8)}_${Date.now()}.${dto.formato}`;
    const ruta = `/reports/${casoId}/${filename}`;

    // E6-02: Operación atómica (create + audit)
    return this.repository.createWithAudit(
      {
        caso_id: casoId,
        tipo_informe: dto.tipo,
        formato: dto.formato,
        ruta_archivo: ruta,
        estado_caso_al_generar: estado ?? 'desconocido',
        generado_por: userId,
      },
      casoId,
      userId,
    );
  }

  async findOne(
    casoId: string,
    reportId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<InformeGenerado> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const report = await this.repository.findById(reportId);
    if (!report || report.caso_id !== casoId) {
      throw new NotFoundException(`Informe ${reportId} no encontrado`);
    }

    return report;
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
