/**
 * DTOs de respuesta para el módulo audit.
 * E6-01: Implementación funcional de audit.
 *
 * Política de seguridad: NO se expone metadata ni contenido sensible
 * de AI (prompt_enviado, respuesta_recibida).
 */

/**
 * Usuario simplificado para respuesta de auditoría.
 */
export class AuditUserDto {
  id: string;
  nombre: string;
}

/**
 * Evento de auditoría individual.
 * Nota: metadata NO se expone por política de seguridad.
 */
export class AuditEventDto {
  id: string;
  tipo: string;
  descripcion: string;
  fecha: string;
  usuario: AuditUserDto;
  estado_origen?: string;
  estado_destino?: string;
  resultado: string;
}

/**
 * Respuesta paginada de eventos de auditoría.
 */
export class PaginatedAuditResponse {
  data: AuditEventDto[];
  total: number;
  page: number;
  per_page: number;
}

/**
 * Genera descripción legible del evento según su tipo.
 */
export function getEventDescription(tipo: string): string {
  const descriptions: Record<string, string> = {
    transicion_estado: 'Transición de estado del caso',
    informe_generado: 'Informe generado',
    revision_supervisor: 'Revisión de supervisor',
    login: 'Inicio de sesión',
    logout: 'Cierre de sesión',
    eliminacion_caso: 'Eliminación de caso',
    ia_query: 'Consulta a asistente IA',
  };
  return descriptions[tipo] || 'Evento de auditoría';
}
