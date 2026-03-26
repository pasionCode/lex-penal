import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { Documento } from '@prisma/client';
import { DocumentsRepository } from './documents.repository';
import { CreateDocumentDto } from './dto/create-document.dto';
import { UpdateDocumentDto } from './dto/update-document.dto';
import { PerfilUsuario, CategoriaDocumento } from '../../types/enums';

// Tipo para documento serializable (BigInt → number)
type DocumentoSerializable = Omit<Documento, 'tamanio_bytes'> & {
  tamanio_bytes: number;
};

@Injectable()
export class DocumentsService {
  constructor(private readonly repository: DocumentsRepository) {}

  private serialize(doc: Documento): DocumentoSerializable {
    return {
      ...doc,
      tamanio_bytes: Number(doc.tamanio_bytes),
    };
  }

  async findAll(
    caseId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<DocumentoSerializable[]> {
    await this.validateCaseAccess(caseId, userId, perfil);
    const docs = await this.repository.findAllByCaseId(caseId);
    return docs.map((d) => this.serialize(d));
  }

  async findOne(
    caseId: string,
    documentId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<DocumentoSerializable> {
    await this.validateCaseAccess(caseId, userId, perfil);
    const document = await this.repository.findById(documentId);
    if (!document || document.caso_id !== caseId) {
      throw new NotFoundException(`Documento ${documentId} no encontrado`);
    }
    return this.serialize(document);
  }

  async create(
    caseId: string,
    dto: CreateDocumentDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<DocumentoSerializable> {
    await this.validateCaseAccess(caseId, userId, perfil);

    const doc = await this.repository.create({
      caso_id: caseId,
      categoria: dto.categoria as unknown as import('@prisma/client').CategoriaDocumento,
      nombre_original: dto.nombre_original,
      nombre_almacenado: dto.nombre_almacenado,
      ruta: dto.ruta,
      mime_type: dto.mime_type,
      tamanio_bytes: BigInt(dto.tamanio_bytes),
      descripcion: dto.descripcion,
      subido_por: userId,
    });
    return this.serialize(doc);
  }

  async update(
    caseId: string,
    documentId: string,
    dto: UpdateDocumentDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<DocumentoSerializable> {
    await this.validateCaseAccess(caseId, userId, perfil);

    const document = await this.repository.findById(documentId);
    if (!document || document.caso_id !== caseId) {
      throw new NotFoundException(`Documento ${documentId} no encontrado`);
    }

    const updated = await this.repository.update(documentId, {
      descripcion: dto.descripcion,
    });
    return this.serialize(updated);
  }

  private async validateCaseAccess(
    caseId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<void> {
    const exists = await this.repository.caseExists(caseId);
    if (!exists) {
      throw new NotFoundException(`Caso ${caseId} no encontrado`);
    }

    if (perfil === PerfilUsuario.ESTUDIANTE) {
      const responsable = await this.repository.getCaseResponsable(caseId);
      if (responsable !== userId) {
        throw new ForbiddenException('Sin acceso a este caso');
      }
    }
  }
}
