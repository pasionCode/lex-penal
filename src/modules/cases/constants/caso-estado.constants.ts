/**
 * Constantes para la máquina de estados del caso.
 * Fuente canónica: ADR-003-maquina-de-estados-del-caso.md
 */

import { EstadoCaso, PerfilUsuario } from '../../../types/enums';

/**
 * Matriz de transiciones válidas.
 * Cada clave es un estado origen, cada valor es un array de estados destino válidos.
 */
export const TRANSICIONES_VALIDAS: Record<EstadoCaso, EstadoCaso[]> = {
  [EstadoCaso.BORRADOR]: [EstadoCaso.EN_ANALISIS],
  [EstadoCaso.EN_ANALISIS]: [EstadoCaso.PENDIENTE_REVISION],
  [EstadoCaso.PENDIENTE_REVISION]: [EstadoCaso.DEVUELTO, EstadoCaso.APROBADO_SUPERVISOR],
  [EstadoCaso.DEVUELTO]: [EstadoCaso.EN_ANALISIS],
  [EstadoCaso.APROBADO_SUPERVISOR]: [EstadoCaso.LISTO_PARA_CLIENTE],
  [EstadoCaso.LISTO_PARA_CLIENTE]: [EstadoCaso.CERRADO],
  [EstadoCaso.CERRADO]: [],
};

/**
 * Permisos de transición por perfil.
 * Formato: 'estado_origen→estado_destino': [perfiles permitidos]
 */
export const PERMISOS_TRANSICION: Record<string, PerfilUsuario[]> = {
  'borrador→en_analisis': [
    PerfilUsuario.ESTUDIANTE,
    PerfilUsuario.SUPERVISOR,
    PerfilUsuario.ADMINISTRADOR,
  ],
  'en_analisis→pendiente_revision': [
    PerfilUsuario.ESTUDIANTE,
    PerfilUsuario.SUPERVISOR,
    PerfilUsuario.ADMINISTRADOR,
  ],
  'pendiente_revision→devuelto': [
    PerfilUsuario.SUPERVISOR,
    PerfilUsuario.ADMINISTRADOR,
  ],
  'pendiente_revision→aprobado_supervisor': [
    PerfilUsuario.SUPERVISOR,
    PerfilUsuario.ADMINISTRADOR,
  ],
  'devuelto→en_analisis': [
    PerfilUsuario.ESTUDIANTE,
    PerfilUsuario.SUPERVISOR,
    PerfilUsuario.ADMINISTRADOR,
  ],
  'aprobado_supervisor→listo_para_cliente': [
    PerfilUsuario.SUPERVISOR,
    PerfilUsuario.ADMINISTRADOR,
  ],
  'listo_para_cliente→cerrado': [
    PerfilUsuario.SUPERVISOR,
    PerfilUsuario.ADMINISTRADOR,
  ],
};

/**
 * Estados que permiten escritura en herramientas operativas.
 * Regla: solo estados de trabajo activo permiten edición.
 * Fuente: R08 (borrador no permite), R09 (cerrado no permite), ADR-003.
 */
export const ESTADOS_ESCRITURA_PERMITIDA: EstadoCaso[] = [
  EstadoCaso.EN_ANALISIS,
  EstadoCaso.DEVUELTO,
];

/**
 * Estados que bloquean escritura en herramientas operativas.
 * Incluye APROBADO_SUPERVISOR: una vez aprobado, el caso queda sellado.
 * Si hay corrección posterior, debe devolverse a EN_ANALISIS.
 */
export const ESTADOS_ESCRITURA_BLOQUEADA: EstadoCaso[] = [
  EstadoCaso.BORRADOR,
  EstadoCaso.PENDIENTE_REVISION,
  EstadoCaso.APROBADO_SUPERVISOR,
  EstadoCaso.LISTO_PARA_CLIENTE,
  EstadoCaso.CERRADO,
];

/**
 * Bloques del checklist según U008.
 * Se generan automáticamente al activar un caso (R08).
 */
export const BLOQUES_CHECKLIST_U008 = [
  { codigo: 'B01', nombre: 'Hechos y línea de tiempo', critico: true },
  { codigo: 'B02', nombre: 'Problema jurídico', critico: true },
  { codigo: 'B03', nombre: 'Análisis de tipicidad', critico: true },
  { codigo: 'B04', nombre: 'Análisis de antijuridicidad', critico: true },
  { codigo: 'B05', nombre: 'Análisis de culpabilidad', critico: true },
  { codigo: 'B06', nombre: 'Matriz probatoria', critico: true },
  { codigo: 'B07', nombre: 'Ruta procesal', critico: true },
  { codigo: 'B08', nombre: 'Riesgos y estrategia', critico: true },
  { codigo: 'B09', nombre: 'Dosimetría y beneficios', critico: false },
  { codigo: 'B10', nombre: 'Salidas alternativas', critico: false },
  { codigo: 'B11', nombre: 'Explicación al cliente', critico: true },
  { codigo: 'B12', nombre: 'Conclusión operativa', critico: true },
] as const;

/**
 * Genera la clave de permiso para una transición.
 */
export function claveTransicion(origen: EstadoCaso, destino: EstadoCaso): string {
  return `${origen}→${destino}`;
}
