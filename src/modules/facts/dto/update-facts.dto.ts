import { EstadoHecho, IncidenciaJuridica } from '../../../types/enums';

export class FactItemDto {
  orden!: number;
  descripcion!: string;
  estado_hecho!: EstadoHecho;
  fuente?: string;
  incidencia_juridica?: IncidenciaJuridica;
}

/** PUT reemplaza la lista completa. Omitir un elemento implica eliminarlo. */
export class UpdateFactsDto {
  hechos!: FactItemDto[];
}
