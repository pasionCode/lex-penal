/** Entrada append-only de la línea de tiempo del caso. */
export class CreateTimelineEntryDto {
  orden!: number;
  fecha?: string;
  descripcion!: string;
  fuente?: string;
}
