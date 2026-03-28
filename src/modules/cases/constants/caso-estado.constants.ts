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
 * Items del checklist U008 — Taxonomía mínima.
 * 1 item por bloque para destrabar guardas.
 * Expandible en fases posteriores.
 *
 * E5-05: Resuelve D-05 (bootstrap sin items).
 */
export const ITEMS_CHECKLIST_U008: Record<string, { codigo: string; descripcion: string }[]> = {
  B01: [{ codigo: 'B01_01', descripcion: 'Hechos y línea de tiempo verificados' }],
  B02: [{ codigo: 'B02_01', descripcion: 'Problema jurídico delimitado' }],
  B03: [{ codigo: 'B03_01', descripcion: 'Tipicidad analizada' }],
  B04: [{ codigo: 'B04_01', descripcion: 'Antijuridicidad analizada' }],
  B05: [{ codigo: 'B05_01', descripcion: 'Culpabilidad analizada' }],
  B06: [{ codigo: 'B06_01', descripcion: 'Matriz probatoria consolidada' }],
  B07: [{ codigo: 'B07_01', descripcion: 'Ruta procesal definida' }],
  B08: [{ codigo: 'B08_01', descripcion: 'Riesgos y estrategia documentados' }],
  B09: [{ codigo: 'B09_01', descripcion: 'Dosimetría y beneficios revisados' }],
  B10: [{ codigo: 'B10_01', descripcion: 'Salidas alternativas evaluadas' }],
  B11: [{ codigo: 'B11_01', descripcion: 'Explicación al cliente preparada' }],
  B12: [{ codigo: 'B12_01', descripcion: 'Conclusión operativa elaborada' }],
};

/**
 * Genera la clave de permiso para una transición.
 */
export function claveTransicion(origen: EstadoCaso, destino: EstadoCaso): string {
  return `${origen}→${destino}`;
}
