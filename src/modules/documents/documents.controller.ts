import {
  Controller,
  Get,
  Put,
  Post,
  Param,
  Body,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { DocumentsService } from './documents.service';
import { CreateDocumentDto } from './dto/create-document.dto';
import { UpdateDocumentDto } from './dto/update-document.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PerfilUsuario } from '../../types/enums';

/**
 * Gestión de documentos referenciados del caso.
 * GET  /api/v1/cases/:caseId/documents              → Listar
 * POST /api/v1/cases/:caseId/documents              → Registrar documento referenciado
 * GET  /api/v1/cases/:caseId/documents/:documentId  → Detalle
 * PUT  /api/v1/cases/:caseId/documents/:documentId  → Actualizar descripción
 *
 * El módulo no realiza subida real de archivos.
 * Persiste metadatos referenciados del documento (`ruta`, `nombre_almacenado`,
 * `mime_type`, `tamanio_bytes`) y permite edición limitada solo de `descripcion`.
 * No hay DELETE ni reemplazo binario.
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

  @Put(':documentId')
  async update(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('documentId', ParseUUIDPipe) documentId: string,
    @Body() dto: UpdateDocumentDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.service.update(caseId, documentId, dto, user.sub, user.perfil as PerfilUsuario);
  }
}
