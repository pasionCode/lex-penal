/** Envoltorio estándar de respuesta de la API. */
export interface ApiResponse<T> {
  data: T;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  per_page: number;
}

export interface ApiError {
  error: string;
  mensaje: string;
  detalles?: string[];
}
