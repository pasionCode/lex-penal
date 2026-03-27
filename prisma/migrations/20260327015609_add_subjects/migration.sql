-- CreateEnum
CREATE TYPE "TipoSujeto" AS ENUM ('victima', 'imputado', 'testigo', 'apoderado', 'otro');

-- CreateEnum
CREATE TYPE "TipoIdentificacion" AS ENUM ('CC', 'TI', 'CE', 'PAS', 'NIT', 'otro');

-- CreateTable
CREATE TABLE "subjects" (
    "id" UUID NOT NULL,
    "caso_id" UUID NOT NULL,
    "tipo" "TipoSujeto" NOT NULL,
    "nombre" VARCHAR(120) NOT NULL,
    "identificacion" VARCHAR(40),
    "tipo_identificacion" "TipoIdentificacion",
    "contacto" VARCHAR(120),
    "direccion" VARCHAR(255),
    "notas" TEXT,
    "creado_en" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actualizado_en" TIMESTAMP(3) NOT NULL,
    "creado_por" UUID NOT NULL,
    "actualizado_por" UUID,

    CONSTRAINT "subjects_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "subjects_caso_id_idx" ON "subjects"("caso_id");

-- AddForeignKey
ALTER TABLE "subjects" ADD CONSTRAINT "subjects_caso_id_fkey" FOREIGN KEY ("caso_id") REFERENCES "casos"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subjects" ADD CONSTRAINT "subjects_creado_por_fkey" FOREIGN KEY ("creado_por") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subjects" ADD CONSTRAINT "subjects_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE CASCADE;
