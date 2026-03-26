/**
 * Enums canónicos del dominio LexPenal.
 * Fuente: MODELO_DATOS_v3.md
 */

export enum EstadoCaso {
  BORRADOR = 'borrador',
  EN_ANALISIS = 'en_analisis',
  PENDIENTE_REVISION = 'pendiente_revision',
  DEVUELTO = 'devuelto',
  APROBADO_SUPERVISOR = 'aprobado_supervisor',
  LISTO_PARA_CLIENTE = 'listo_para_cliente',
  CERRADO = 'cerrado',
}

export enum PerfilUsuario {
  ESTUDIANTE = 'estudiante',
  SUPERVISOR = 'supervisor',
  ADMINISTRADOR = 'administrador',
}

export enum SituacionLibertad {
  LIBRE = 'libre',
  DETENIDO = 'detenido',
}

export enum EstadoHecho {
  ACREDITADO = 'acreditado',
  REFERIDO = 'referido',
  DISCUTIDO = 'discutido',
}

export enum IncidenciaJuridica {
  TIPICIDAD = 'tipicidad',
  ANTIJURIDICIDAD = 'antijuridicidad',
  CULPABILIDAD = 'culpabilidad',
  PROCEDIMIENTO = 'procedimiento',
}

export enum TipoPrueba {
  TESTIMONIAL = 'testimonial',
  DOCUMENTAL = 'documental',
  PERICIAL = 'pericial',
  REAL = 'real',
  OTRO = 'otro',
}

export enum EvaluacionProbatoria {
  OK = 'ok',
  CUESTIONABLE = 'cuestionable',
  DEFICIENTE = 'deficiente',
}

export enum Probabilidad {
  ALTA = 'alta',
  MEDIA = 'media',
  BAJA = 'baja',
}

export enum Impacto {
  ALTO = 'alto',
  MEDIO = 'medio',
  BAJO = 'bajo',
}

export enum Prioridad {
  CRITICA = 'critica',
  ALTA = 'alta',
  MEDIA = 'media',
  BAJA = 'baja',
}

export enum EstadoMitigacion {
  PENDIENTE = 'pendiente',
  EN_CURSO = 'en_curso',
  MITIGADO = 'mitigado',
  ACEPTADO = 'aceptado',
}

export enum ResultadoRevision {
  APROBADO = 'aprobado',
  DEVUELTO = 'devuelto',
}

export enum TipoInforme {
  RESUMEN_EJECUTIVO = 'resumen_ejecutivo',
  CONCLUSION_OPERATIVA = 'conclusion_operativa',
  CONTROL_CALIDAD = 'control_calidad',
  RIESGOS = 'riesgos',
  CRONOLOGICO = 'cronologico',
  REVISION_SUPERVISOR = 'revision_supervisor',
  AGENDA_VENCIMIENTOS = 'agenda_vencimientos',
}

export enum FormatoInforme {
  PDF = 'pdf',
  DOCX = 'docx',
}

export enum EstadoLlamadaIA {
  EXITOSA = 'exitosa',
  FALLIDA = 'fallida',
  TIMEOUT = 'timeout',
}

export enum ResultadoAuditoria {
  EXITOSO = 'exitoso',
  RECHAZADO = 'rechazado',
}

export enum CategoriaDocumento {
  ACUSACION = 'acusacion',
  DEFENSA = 'defensa',
  CLIENTE = 'cliente',
  ACTUACION = 'actuacion',
  INFORME = 'informe',
  EVIDENCIA = 'evidencia',
  ANEXO = 'anexo',
  OTRO = 'otro',
}

export enum TipoEvento {
  TRANSICION_ESTADO = 'transicion_estado',
  INFORME_GENERADO = 'informe_generado',
  REVISION_SUPERVISOR = 'revision_supervisor',
  LOGIN = 'login',
  LOGOUT = 'logout',
  ELIMINACION_CASO = 'eliminacion_caso',
  IA_QUERY = 'ia_query',
}

/**
 * Valores canónicos del campo herramienta en POST /api/v1/ai/query.
 * Convención oficial: snake_case (definido en Sprint 8, E4).
 */
export enum HerramientaIA {
  BASIC_INFO = 'basic_info',
  FACTS = 'facts',
  EVIDENCE = 'evidence',
  RISKS = 'risks',
  STRATEGY = 'strategy',
  CLIENT_BRIEFING = 'client_briefing',
  CHECKLIST = 'checklist',
  CONCLUSION = 'conclusion',
}
