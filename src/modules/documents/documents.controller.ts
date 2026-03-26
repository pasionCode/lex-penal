import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { DocumentsService } from './documents.service';
import { CreateDocumentDto } from './dto/create-document.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * Gestión de metadatos de documentos del caso.
 * GET  /api/v1/cases/:caseId/documents           → Listar
 * POST /api/v1/cases/:caseId/documents           → Registrar metadatos
 * GET  /api/v1/cases/:caseId/documents/:docId    → Detalle
 * 
 * Nota: Sprint 10 — solo metadatos, sin subida real de archivos.
 * Entidad append-only: no hay PUT ni DELETE.
 */
@Controller('cases/:caseId/documents')
@UseGuards(JwtAuthGuard)
export class DocumentsController {
  constructor(private readonly service: DocumentsService) {}

  @Get()
  async findAll(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findAll(caseId, user.sub, user.perfil as PerfilUsuario);
  }

  @Post()
  async create(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: CreateDocumentDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.create(caseId, dto, user.sub, user.perfil as PerfilUsuario);
  }

  @Get(':documentId')
  async findOne(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('documentId', ParseUUIDPipe) documentId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.findOne(caseId, documentId, user.sub, user.perfil as PerfilUsuario);
  }
}
