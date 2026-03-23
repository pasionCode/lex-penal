import { Controller, Post, Body } from '@nestjs/common';
import { AIService } from './ai.service';
import { AIQueryDto } from './dto/ai-query.dto';

/**
 * POST /api/v1/ai/query
 *
 * 200: respuesta + tokens_entrada + tokens_salida + modelo_usado
 * 503: proveedor no disponible (caso y herramientas siguen operando)
 * 500: proveedor respondió pero falló el log — no se entrega la respuesta (RI-IA-02)
 * 422: valor de herramienta no es uno de los 8 canónicos
 * No disponible para casos en estado cerrado (R09).
 */
@Controller('ai')
export class AIController {
  constructor(private readonly service: AIService) {}

  @Post('query')
  query(@Body() _dto: AIQueryDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
