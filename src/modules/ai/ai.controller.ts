import {
  Controller,
  Post,
  Body,
  UseGuards,
} from '@nestjs/common';
import { AIService } from './ai.service';
import { AIQueryDto } from './dto/ai-query.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * Consultas IA del caso.
 * POST /api/v1/ai/query
 */
@Controller('ai')
@UseGuards(JwtAuthGuard)
export class AIController {
  constructor(private readonly service: AIService) {}

  @Post('query')
  async query(
    @Body() dto: AIQueryDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.query(dto, user.sub, user.perfil as PerfilUsuario);
  }
}
