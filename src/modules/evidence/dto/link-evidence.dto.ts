import { IsUUID } from 'class-validator';

/**
 * DTO para vincular prueba a hecho.
 * PATCH /api/v1/cases/:caseId/evidence/:evidenceId/link
 */
export class LinkEvidenceDto {
  @IsUUID('4', { message: 'hecho_id debe ser un UUID válido' })
  hecho_id!: string;
}
