import {
  Controller,
  Get,
  Put,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ConclusionService } from './conclusion.service';
import { UpdateConclusionDto } from './dto/update-conclusion.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * Conclusión operativa — recurso único por caso.
 * GET  /api/v1/cases/:caseId/conclusion
 * PUT  /api/v1/cases/:caseId/conclusion
 */
@Controller('cases/:caseId/conclusion')
@UseGuards(JwtAuthGuard)
export class ConclusionController {
  constructor(private readonly service: ConclusionService) {}

  @Get()
  async findOne(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findByCaseId(caseId, user.sub, user.perfil as PerfilUsuario);
  }

  @Put()
  async update(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: UpdateConclusionDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.update(caseId, dto, user.sub, user.perfil as PerfilUsuario);
  }
}
