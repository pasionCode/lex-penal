export class SubjectResponseDto {
  id!: string;
  caso_id!: string;
  tipo!: string;
  nombre!: string;
  identificacion?: string | null;
  tipo_identificacion?: string | null;
  contacto?: string | null;
  direccion?: string | null;
  notas?: string | null;
  creado_en!: Date;
  actualizado_en!: Date;
  creado_por!: string;
  actualizado_por?: string | null;
}
