-- CreateEnum
CREATE TYPE "PerfilUsuario" AS ENUM ('estudiante', 'supervisor', 'administrador');

-- CreateEnum
CREATE TYPE "SituacionLibertad" AS ENUM ('libre', 'detenido');

-- CreateEnum
CREATE TYPE "EstadoCaso" AS ENUM ('borrador', 'en_analisis', 'pendiente_revision', 'devuelto', 'aprobado_supervisor', 'listo_para_cliente', 'cerrado');

-- CreateEnum
CREATE TYPE "EstadoHecho" AS ENUM ('acreditado', 'referido', 'discutido');

-- CreateEnum
CREATE TYPE "IncidenciaJuridica" AS ENUM ('tipicidad', 'antijuridicidad', 'culpabilidad', 'procedimiento');

-- CreateEnum
CREATE TYPE "TipoPrueba" AS ENUM ('testimonial', 'documental', 'pericial', 'real', 'otro');

-- CreateEnum
CREATE TYPE "EvaluacionProbatoria" AS ENUM ('ok', 'cuestionable', 'deficiente');

-- CreateEnum
CREATE TYPE "Probabilidad" AS ENUM ('alta', 'media', 'baja');

-- CreateEnum
CREATE TYPE "Impacto" AS ENUM ('alto', 'medio', 'bajo');

-- CreateEnum
CREATE TYPE "Prioridad" AS ENUM ('critica', 'alta', 'media', 'baja');

-- CreateEnum
CREATE TYPE "EstadoMitigacion" AS ENUM ('pendiente', 'en_curso', 'mitigado', 'aceptado');

-- CreateEnum
CREATE TYPE "ResultadoRevision" AS ENUM ('aprobado', 'devuelto');

-- CreateEnum
CREATE TYPE "CategoriaDocumento" AS ENUM ('acusacion', 'defensa', 'cliente', 'actuacion', 'informe', 'evidencia', 'anexo', 'otro');

-- CreateEnum
CREATE TYPE "TipoInforme" AS ENUM ('resumen_ejecutivo', 'conclusion_operativa', 'control_calidad', 'riesgos', 'cronologico', 'revision_supervisor', 'agenda_vencimientos');

-- CreateEnum
CREATE TYPE "FormatoInforme" AS ENUM ('pdf', 'docx');

-- CreateEnum
CREATE TYPE "EstadoLlamadaIA" AS ENUM ('exitosa', 'fallida', 'timeout');

-- CreateEnum
CREATE TYPE "ResultadoAuditoria" AS ENUM ('exitoso', 'rechazado');

-- CreateEnum
CREATE TYPE "TipoEvento" AS ENUM ('transicion_estado', 'informe_generado', 'revision_supervisor', 'login', 'logout', 'eliminacion_caso', 'ia_query');

-- CreateEnum
CREATE TYPE "HerramientaIA" AS ENUM ('basic_info', 'facts', 'evidence', 'risks', 'strategy', 'client_briefing', 'checklist', 'conclusion');

-- CreateTable
CREATE TABLE "usuarios" (
    "id" UUID NOT NULL,
    "nombre" VARCHAR(120) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "perfil" "PerfilUsuario" NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "clientes" (
    "id" UUID NOT NULL,
    "nombre" VARCHAR(120) NOT NULL,
    "documento" VARCHAR(30) NOT NULL,
    "tipo_documento" VARCHAR(20) NOT NULL,
    "contacto" TEXT,
    "situacion_libertad" "SituacionLibertad" NOT NULL,
    "lugar_detencion" VARCHAR(200),
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID NOT NULL,
    "actualizado_por" UUID,

    CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "casos" (
    "id" UUID NOT NULL,
    "cliente_id" UUID NOT NULL,
    "responsable_id" UUID NOT NULL,
    "radicado" VARCHAR(80) NOT NULL,
    "despacho" VARCHAR(200),
    "fecha_apertura" DATE,
    "delito_imputado" VARCHAR(300) NOT NULL,
    "agravantes" TEXT,
    "regimen_procesal" VARCHAR(100) NOT NULL,
    "etapa_procesal" VARCHAR(100) NOT NULL,
    "proxima_actuacion" TEXT,
    "fecha_proxima_actuacion" DATE,
    "responsable_proxima_actuacion" VARCHAR(120),
    "observaciones" TEXT,
    "estado_actual" "EstadoCaso" NOT NULL DEFAULT 'borrador',
    "estado_anterior" "EstadoCaso",
    "fecha_cambio_estado" TIMESTAMP(3),
    "usuario_cambio_estado" UUID,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID NOT NULL,
    "actualizado_por" UUID,

    CONSTRAINT "casos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hechos" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "orden" INTEGER NOT NULL,
    "descripcion" TEXT NOT NULL,
    "estado_hecho" "EstadoHecho" NOT NULL,
    "fuente" TEXT,
    "incidencia_juridica" "IncidenciaJuridica",
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID NOT NULL,
    "actualizado_por" UUID,

    CONSTRAINT "hechos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "linea_tiempo" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "fecha_evento" DATE NOT NULL,
    "descripcion" TEXT NOT NULL,
    "orden" INTEGER NOT NULL,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "creado_por" UUID NOT NULL,

    CONSTRAINT "linea_tiempo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pruebas" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "hecho_id" UUID,
    "hecho_descripcion_libre" TEXT,
    "descripcion" TEXT NOT NULL,
    "tipo_prueba" "TipoPrueba" NOT NULL,
    "licitud" "EvaluacionProbatoria" NOT NULL,
    "legalidad" "EvaluacionProbatoria" NOT NULL,
    "suficiencia" "EvaluacionProbatoria" NOT NULL,
    "credibilidad" "EvaluacionProbatoria" NOT NULL,
    "posicion_defensiva" TEXT,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID NOT NULL,
    "actualizado_por" UUID,

    CONSTRAINT "pruebas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "riesgos" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "descripcion" TEXT NOT NULL,
    "probabilidad" "Probabilidad" NOT NULL,
    "impacto" "Impacto" NOT NULL,
    "prioridad" "Prioridad" NOT NULL,
    "estrategia_mitigacion" TEXT,
    "estado_mitigacion" "EstadoMitigacion" NOT NULL DEFAULT 'pendiente',
    "plazo_accion" DATE,
    "responsable_id" UUID,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID NOT NULL,
    "actualizado_por" UUID,

    CONSTRAINT "riesgos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "estrategia" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "linea_principal" TEXT,
    "fundamento_juridico" TEXT,
    "fundamento_probatorio" TEXT,
    "linea_subsidiaria" TEXT,
    "posicion_allanamiento" TEXT,
    "posicion_preacuerdo" TEXT,
    "posicion_juicio" TEXT,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID NOT NULL,
    "actualizado_por" UUID,

    CONSTRAINT "estrategia_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "actuaciones" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "descripcion" TEXT NOT NULL,
    "fecha" DATE,
    "responsable_id" UUID,
    "responsable_externo" VARCHAR(120),
    "completada" BOOLEAN NOT NULL DEFAULT false,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID NOT NULL,
    "actualizado_por" UUID,

    CONSTRAINT "actuaciones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "explicacion_cliente" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "delito_explicado" TEXT,
    "riesgos_informados" TEXT,
    "panorama_probatorio" TEXT,
    "beneficios_informados" TEXT,
    "opciones_explicadas" TEXT,
    "recomendacion" TEXT,
    "decision_cliente" TEXT,
    "fecha_explicacion" DATE,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID NOT NULL,
    "actualizado_por" UUID,

    CONSTRAINT "explicacion_cliente_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_bloques" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "codigo_bloque" VARCHAR(10) NOT NULL,
    "nombre_bloque" VARCHAR(120) NOT NULL,
    "critico" BOOLEAN NOT NULL DEFAULT true,
    "completado" BOOLEAN NOT NULL DEFAULT false,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "checklist_bloques_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checklist_items" (
    "id" UUID NOT NULL,
    "bloque_id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "codigo_item" VARCHAR(10) NOT NULL,
    "descripcion" TEXT NOT NULL,
    "marcado" BOOLEAN NOT NULL DEFAULT false,
    "marcado_en" TIMESTAMP(3),
    "marcado_por" UUID,

    CONSTRAINT "checklist_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conclusion_operativa" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "hechos_sintesis" TEXT,
    "cargo_imputado" TEXT,
    "evaluacion_dogmatica" TEXT,
    "fisuras_fortalezas" TEXT,
    "fortalezas_acusacion" TEXT,
    "debilidades_acusacion" TEXT,
    "prueba_defensa" TEXT,
    "etapa_texto" TEXT,
    "oportunidades" TEXT,
    "rangos_pena" TEXT,
    "beneficios" TEXT,
    "restricciones_subrogados" TEXT,
    "riesgos_prioritarios" TEXT,
    "opcion_a" TEXT,
    "consecuencias_a" TEXT,
    "opcion_b" TEXT,
    "consecuencias_b" TEXT,
    "opcion_c" TEXT,
    "consecuencias_c" TEXT,
    "recomendacion" TEXT,
    "fundamento_recomendacion" TEXT,
    "condicion_vigencia" TEXT,
    "observaciones" TEXT,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID NOT NULL,
    "actualizado_por" UUID,

    CONSTRAINT "conclusion_operativa_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "revision_supervisor" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "supervisor_id" UUID NOT NULL,
    "version_revision" INTEGER NOT NULL DEFAULT 1,
    "vigente" BOOLEAN NOT NULL DEFAULT true,
    "observaciones" TEXT NOT NULL,
    "fecha_revision" DATE,
    "resultado" "ResultadoRevision" NOT NULL,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "creado_por" UUID NOT NULL,

    CONSTRAINT "revision_supervisor_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "documentos" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "categoria" "CategoriaDocumento" NOT NULL,
    "nombre_original" VARCHAR(255) NOT NULL,
    "nombre_almacenado" VARCHAR(255) NOT NULL,
    "ruta" TEXT NOT NULL,
    "mime_type" VARCHAR(100) NOT NULL,
    "tamanio_bytes" BIGINT NOT NULL,
    "descripcion" TEXT,
    "subido_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "subido_por" UUID NOT NULL,

    CONSTRAINT "documentos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "informes_generados" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "tipo_informe" "TipoInforme" NOT NULL,
    "formato" "FormatoInforme" NOT NULL,
    "ruta_archivo" TEXT NOT NULL,
    "estado_caso_al_generar" VARCHAR(50) NOT NULL,
    "generado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "generado_por" UUID NOT NULL,

    CONSTRAINT "informes_generados_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_request_log" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "usuario_id" UUID NOT NULL,
    "herramienta" "HerramientaIA" NOT NULL,
    "proveedor" VARCHAR(60) NOT NULL,
    "modelo" VARCHAR(80) NOT NULL,
    "prompt_enviado" TEXT NOT NULL,
    "respuesta_recibida" TEXT,
    "tokens_entrada" INTEGER,
    "tokens_salida" INTEGER,
    "duracion_ms" INTEGER,
    "estado_llamada" "EstadoLlamadaIA" NOT NULL,
    "error_mensaje" TEXT,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ai_request_log_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "eventos_auditoria" (
    "id" UUID NOT NULL,
    "caso_id" UUID,
    "usuario_id" UUID NOT NULL,
    "tipo_evento" "TipoEvento" NOT NULL,
    "estado_origen" VARCHAR(50),
    "estado_destino" VARCHAR(50),
    "resultado" "ResultadoAuditoria" NOT NULL,
    "motivo_rechazo" TEXT,
    "metadata" JSONB,
    "fecha_evento" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "eventos_auditoria_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");

-- CreateIndex
CREATE UNIQUE INDEX "clientes_tipo_documento_documento_key" ON "clientes"("tipo_documento", "documento");

-- CreateIndex
CREATE UNIQUE INDEX "casos_radicado_key" ON "casos"("radicado");

-- CreateIndex
CREATE INDEX "casos_cliente_id_idx" ON "casos"("cliente_id");

-- CreateIndex
CREATE INDEX "casos_responsable_id_idx" ON "casos"("responsable_id");

-- CreateIndex
CREATE INDEX "casos_estado_actual_idx" ON "casos"("estado_actual");

-- CreateIndex
CREATE INDEX "hechos_caso_id_idx" ON "hechos"("caso_id");

-- CreateIndex
CREATE UNIQUE INDEX "hechos_caso_id_orden_key" ON "hechos"("caso_id", "orden");

-- CreateIndex
CREATE INDEX "linea_tiempo_caso_id_idx" ON "linea_tiempo"("caso_id");

-- CreateIndex
CREATE UNIQUE INDEX "linea_tiempo_caso_id_orden_key" ON "linea_tiempo"("caso_id", "orden");

-- CreateIndex
CREATE INDEX "pruebas_caso_id_idx" ON "pruebas"("caso_id");

-- CreateIndex
CREATE INDEX "pruebas_hecho_id_idx" ON "pruebas"("hecho_id");

-- CreateIndex
CREATE INDEX "riesgos_caso_id_idx" ON "riesgos"("caso_id");

-- CreateIndex
CREATE INDEX "riesgos_prioridad_idx" ON "riesgos"("prioridad");

-- CreateIndex
CREATE INDEX "riesgos_estado_mitigacion_idx" ON "riesgos"("estado_mitigacion");

-- CreateIndex
CREATE INDEX "riesgos_responsable_id_idx" ON "riesgos"("responsable_id");

-- CreateIndex
CREATE UNIQUE INDEX "estrategia_caso_id_key" ON "estrategia"("caso_id");

-- CreateIndex
CREATE INDEX "actuaciones_caso_id_idx" ON "actuaciones"("caso_id");

-- CreateIndex
CREATE INDEX "actuaciones_fecha_idx" ON "actuaciones"("fecha");

-- CreateIndex
CREATE INDEX "actuaciones_responsable_id_idx" ON "actuaciones"("responsable_id");

-- CreateIndex
CREATE UNIQUE INDEX "explicacion_cliente_caso_id_key" ON "explicacion_cliente"("caso_id");

-- CreateIndex
CREATE INDEX "checklist_bloques_caso_id_idx" ON "checklist_bloques"("caso_id");

-- CreateIndex
CREATE UNIQUE INDEX "checklist_bloques_caso_id_codigo_bloque_key" ON "checklist_bloques"("caso_id", "codigo_bloque");

-- CreateIndex
CREATE INDEX "checklist_items_bloque_id_idx" ON "checklist_items"("bloque_id");

-- CreateIndex
CREATE INDEX "checklist_items_caso_id_idx" ON "checklist_items"("caso_id");

-- CreateIndex
CREATE UNIQUE INDEX "checklist_items_bloque_id_codigo_item_key" ON "checklist_items"("bloque_id", "codigo_item");

-- CreateIndex
CREATE UNIQUE INDEX "conclusion_operativa_caso_id_key" ON "conclusion_operativa"("caso_id");

-- CreateIndex
CREATE INDEX "revision_supervisor_caso_id_idx" ON "revision_supervisor"("caso_id");

-- CreateIndex
CREATE INDEX "revision_supervisor_supervisor_id_idx" ON "revision_supervisor"("supervisor_id");

-- CreateIndex
CREATE UNIQUE INDEX "revision_supervisor_caso_id_version_revision_key" ON "revision_supervisor"("caso_id", "version_revision");

-- CreateIndex
CREATE INDEX "documentos_caso_id_idx" ON "documentos"("caso_id");

-- CreateIndex
CREATE INDEX "documentos_categoria_idx" ON "documentos"("categoria");

-- CreateIndex
CREATE INDEX "informes_generados_caso_id_idx" ON "informes_generados"("caso_id");

-- CreateIndex
CREATE INDEX "ai_request_log_caso_id_idx" ON "ai_request_log"("caso_id");

-- CreateIndex
CREATE INDEX "ai_request_log_usuario_id_idx" ON "ai_request_log"("usuario_id");

-- CreateIndex
CREATE INDEX "ai_request_log_creado_en_idx" ON "ai_request_log"("creado_en");

-- CreateIndex
CREATE INDEX "eventos_auditoria_caso_id_idx" ON "eventos_auditoria"("caso_id");

-- CreateIndex
CREATE INDEX "eventos_auditoria_usuario_id_idx" ON "eventos_auditoria"("usuario_id");

-- CreateIndex
CREATE INDEX "eventos_auditoria_tipo_evento_idx" ON "eventos_auditoria"("tipo_evento");

-- CreateIndex
CREATE INDEX "eventos_auditoria_fecha_evento_idx" ON "eventos_auditoria"("fecha_evento");

-- AddForeignKey
ALTER TABLE "usuarios" ADD CONSTRAINT "usuarios_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "clientes" ADD CONSTRAINT "clientes_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "clientes" ADD CONSTRAINT "clientes_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "casos" ADD CONSTRAINT "casos_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "casos" ADD CONSTRAINT "casos_responsable_id_fkey" FOREIGN KEY ("responsable_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "casos" ADD CONSTRAINT "casos_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "casos" ADD CONSTRAINT "casos_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "casos" ADD CONSTRAINT "casos_usuario_cambio_estado_fkey" FOREIGN KEY ("usuario_cambio_estado") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hechos" ADD CONSTRAINT "hechos_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hechos" ADD CONSTRAINT "hechos_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hechos" ADD CONSTRAINT "hechos_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "linea_tiempo" ADD CONSTRAINT "linea_tiempo_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "linea_tiempo" ADD CONSTRAINT "linea_tiempo_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pruebas" ADD CONSTRAINT "pruebas_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pruebas" ADD CONSTRAINT "pruebas_hecho_id_fkey" FOREIGN KEY ("hecho_id") REFERENCES "hechos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pruebas" ADD CONSTRAINT "pruebas_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pruebas" ADD CONSTRAINT "pruebas_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "riesgos" ADD CONSTRAINT "riesgos_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "riesgos" ADD CONSTRAINT "riesgos_responsable_id_fkey" FOREIGN KEY ("responsable_id") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "riesgos" ADD CONSTRAINT "riesgos_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "riesgos" ADD CONSTRAINT "riesgos_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "estrategia" ADD CONSTRAINT "estrategia_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "estrategia" ADD CONSTRAINT "estrategia_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "estrategia" ADD CONSTRAINT "estrategia_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "actuaciones" ADD CONSTRAINT "actuaciones_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "actuaciones" ADD CONSTRAINT "actuaciones_responsable_id_fkey" FOREIGN KEY ("responsable_id") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "actuaciones" ADD CONSTRAINT "actuaciones_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "actuaciones" ADD CONSTRAINT "actuaciones_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "explicacion_cliente" ADD CONSTRAINT "explicacion_cliente_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "explicacion_cliente" ADD CONSTRAINT "explicacion_cliente_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "explicacion_cliente" ADD CONSTRAINT "explicacion_cliente_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_bloques" ADD CONSTRAINT "checklist_bloques_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_items" ADD CONSTRAINT "checklist_items_bloque_id_fkey" FOREIGN KEY ("bloque_id") REFERENCES "checklist_bloques"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_items" ADD CONSTRAINT "checklist_items_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "checklist_items" ADD CONSTRAINT "checklist_items_marcado_por_fkey" FOREIGN KEY ("marcado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conclusion_operativa" ADD CONSTRAINT "conclusion_operativa_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conclusion_operativa" ADD CONSTRAINT "conclusion_operativa_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conclusion_operativa" ADD CONSTRAINT "conclusion_operativa_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "revision_supervisor" ADD CONSTRAINT "revision_supervisor_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "revision_supervisor" ADD CONSTRAINT "revision_supervisor_supervisor_id_fkey" FOREIGN KEY ("supervisor_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "revision_supervisor" ADD CONSTRAINT "revision_supervisor_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "documentos" ADD CONSTRAINT "documentos_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "documentos" ADD CONSTRAINT "documentos_subido_por_fkey" FOREIGN KEY ("subido_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "informes_generados" ADD CONSTRAINT "informes_generados_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "informes_generados" ADD CONSTRAINT "informes_generados_generado_por_fkey" FOREIGN KEY ("generado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_request_log" ADD CONSTRAINT "ai_request_log_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_request_log" ADD CONSTRAINT "ai_request_log_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "eventos_auditoria" ADD CONSTRAINT "eventos_auditoria_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "eventos_auditoria" ADD CONSTRAINT "eventos_auditoria_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
