import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { AIRepository } from './ai.repository';
import { AIQueryDto } from './dto/ai-query.dto';
import { PerfilUsuario, EstadoCaso } from '../../types/enums';

export interface AIResponse {
  respuesta: string;
  tokens_entrada: number;
  tokens_salida: number;
  modelo_usado: string;
}

@Injectable()
export class AIService {
  constructor(private readonly repository: AIRepository) {}

  async query(
    dto: AIQueryDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<AIResponse> {
    // Verificar caso existe
    const exists = await this.repository.caseExists(dto.caso_id);
    if (!exists) {
      throw new NotFoundException(`Caso ${dto.caso_id} no encontrado`);
    }

    // Verificar ownership
    if (perfil === PerfilUsuario.ESTUDIANTE) {
      const responsable = await this.repository.getCaseResponsable(dto.caso_id);
      if (responsable !== userId) {
        throw new ForbiddenException('Sin acceso a este caso');
      }
    }

    // No disponible en estado cerrado
    const estado = await this.repository.getCaseState(dto.caso_id);
    if (estado === EstadoCaso.CERRADO) {
      throw new ConflictException('No se permite consulta IA en casos cerrados');
    }

    const startTime = Date.now();

    // MVP: respuesta placeholder (sin proveedor IA real)
    const respuesta = `[MVP] Análisis de ${dto.herramienta} para el caso. Consulta: "${dto.consulta.slice(0, 50)}..."`;
    const tokensEntrada = Math.ceil(dto.consulta.length / 4);
    const tokensSalida = Math.ceil(respuesta.length / 4);

    const duracion = Date.now() - startTime;

    // Registrar en log
    await this.repository.create({
      caso_id: dto.caso_id,
      usuario_id: userId,
      herramienta: dto.herramienta,
      proveedor: 'mvp_placeholder',
      modelo: 'placeholder_v1',
      prompt_enviado: dto.consulta,
      respuesta_recibida: respuesta,
      tokens_entrada: tokensEntrada,
      tokens_salida: tokensSalida,
      duracion_ms: duracion,
      estado_llamada: 'exitosa',
    });

    return {
      respuesta,
      tokens_entrada: tokensEntrada,
      tokens_salida: tokensSalida,
      modelo_usado: 'placeholder_v1',
    };
  }
}
