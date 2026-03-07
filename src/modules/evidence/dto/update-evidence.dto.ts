import { EvaluacionProbatoria, TipoPrueba } from '../../../types/enums';

export class EvidenceItemDto {
  descripcion!: string;
  tipo_prueba!: TipoPrueba;
  hecho_id?: string;
  hecho_descripcion_libre?: string;
  licitud!: EvaluacionProbatoria;
  legalidad!: EvaluacionProbatoria;
  suficiencia!: EvaluacionProbatoria;
  credibilidad!: EvaluacionProbatoria;
  posicion_defensiva?: string;
}

export class UpdateEvidenceDto {
  pruebas!: EvidenceItemDto[];
}
