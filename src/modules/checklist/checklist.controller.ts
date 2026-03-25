import {
  Controller,
  Get,
  Put,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ChecklistService } from './checklist.service';
import { UpdateChecklistDto } from './dto/update-checklist-item.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * Checklist de calidad — jerárquico (bloques + items).
 * GET  /api/v1/cases/:caseId/checklist
 * PUT  /api/v1/cases/:caseId/checklist
 */
@Controller('cases/:caseId/checklist')
@UseGuards(JwtAuthGuard)
export class ChecklistController {
  constructor(private readonly service: ChecklistService) {}

  @Get()
  async findAll(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findByCaseId(caseId, user.sub, user.perfil as PerfilUsuario);
  }

  @Put()
  async updateItems(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: UpdateChecklistDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.updateItems(caseId, dto, user.sub, user.perfil as PerfilUsuario);
  }
}
