import {
  Controller,
  Get,
  Put,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ClientBriefingService } from './client-briefing.service';
import { UpdateClientBriefingDto } from './dto/update-client-briefing.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * Explicación al cliente — recurso único por caso.
 * GET  /api/v1/cases/:caseId/client-briefing
 * PUT  /api/v1/cases/:caseId/client-briefing
 */
@Controller('cases/:caseId/client-briefing')
@UseGuards(JwtAuthGuard)
export class ClientBriefingController {
  constructor(private readonly service: ClientBriefingService) {}

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
    @Body() dto: UpdateClientBriefingDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.update(caseId, dto, user.sub, user.perfil as PerfilUsuario);
  }
}
