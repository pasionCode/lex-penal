import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ReportsService } from './reports.service';
import { GenerateReportDto } from './dto/generate-report.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * Informes generados del caso.
 * GET  /api/v1/cases/:caseId/reports - historial
 * POST /api/v1/cases/:caseId/reports - generar
 * GET  /api/v1/cases/:caseId/reports/:reportId - detalle/descarga
 */
@Controller('cases/:caseId/reports')
@UseGuards(JwtAuthGuard)
export class ReportsController {
  constructor(private readonly service: ReportsService) {}

  @Get()
  async findAll(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findAll(caseId, user.sub, user.perfil as PerfilUsuario);
  }

  @Post()
  async generate(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: GenerateReportDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.generate(caseId, dto, user.sub, user.perfil as PerfilUsuario);
  }

  @Get(':reportId')
  async findOne(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('reportId', ParseUUIDPipe) reportId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findOne(caseId, reportId, user.sub, user.perfil as PerfilUsuario);
  }
}
