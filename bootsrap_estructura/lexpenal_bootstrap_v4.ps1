param(
    [Parameter(Mandatory = $true)]
    [string]$BasePath,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Ensure-Directory {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Write-Utf8BomFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content,
        [switch]$ForceWrite
    )

    $parent = Split-Path -Parent $Path
    if ($parent) { Ensure-Directory -Path $parent }

    if ((Test-Path -LiteralPath $Path) -and (-not $ForceWrite)) {
        Write-Host "[SKIP] $Path"
        return
    }

    $utf8Bom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8Bom)
    Write-Host "[OK]   $Path"
}

function Normalize-BasePath {
    param([string]$Path)
    $expanded = [Environment]::ExpandEnvironmentVariables($Path)
    return [System.IO.Path]::GetFullPath($expanded)
}

$BasePath = Normalize-BasePath -Path $BasePath
Ensure-Directory -Path $BasePath

$dirs = @(
    'docs',
    'docs/00_gobierno',
    'docs/00_gobierno/adrs',
    'docs/01_producto',
    'docs/02_arquitectura',
    'docs/03_datos',
    'docs/04_api',
    'docs/05_frontend',
    'docs/06_backend',
    'docs/07_infraestructura',
    'docs/08_seguridad',
    'docs/09_calidad',
    'docs/10_gestion',
    'docs/11_informes',
    'docs/12_ia',
    'docs/13_operacion',
    'docs/14_legal_funcional',
    'infra',
    'infra/nginx',
    'infra/docker',
    'infra/postgres',
    'scripts',
    'scripts/windows',
    'scripts/linux',
    'src',
    'src/frontend',
    'src/backend',
    'src/shared',
    'tests',
    'tests/unit',
    'tests/integration',
    'tests/e2e',
    'resources',
    'resources/templates',
    'resources/samples',
    'resources/diagrams'
)

foreach ($dir in $dirs) {
    Ensure-Directory -Path (Join-Path $BasePath $dir)
}

$files = @{}

$files['README.md'] = @"
# LexPenal

Sistema de gestion de casos de defensa penal colombiana alineado con la Unidad 8 del Manual de Defensa Penal Colombiana.

## Objetivo
Construir un aplicativo web que permita gestionar casos, clientes, herramientas de analisis, revision de supervisor, checklist vinculante, informes e integracion modular con proveedores de IA.

## Principios base
- El caso es la unidad central del sistema.
- La Unidad 8 gobierna la coherencia funcional del producto.
- El checklist de calidad es vinculante.
- La conclusion operativa no puede validarse sin control de calidad y revision cuando aplique.
- La IA es un modulo desacoplado del nucleo del sistema.

## Estructura principal
- `docs`: documentacion funcional, tecnica y operativa.
- `src`: codigo fuente.
- `infra`: despliegue e infraestructura.
- `scripts`: automatizaciones de soporte.
- `tests`: pruebas.
- `resources`: plantillas, muestras y diagramas.

## Estado esperado de esta base
Este repositorio deja lista la estructura documental del proyecto para permitir desarrollo ordenado, trazabilidad y auditoria tecnica.
"@

$files['docs/MAPA_REPOSITORIO.md'] = @"
# Mapa del repositorio

## Directorios
- `docs/00_gobierno`: alcance, decisiones, ADRs y gobierno documental.
- `docs/01_producto`: vision, objetivos, backlog y flujo funcional.
- `docs/02_arquitectura`: arquitectura logica y tecnica.
- `docs/03_datos`: modelo de datos y catalogos.
- `docs/04_api`: contrato API y endpoints.
- `docs/05_frontend`: lineamientos de interfaz y navegacion.
- `docs/06_backend`: servicios, reglas y capas.
- `docs/07_infraestructura`: despliegue en VM y operacion tecnica.
- `docs/08_seguridad`: controles y trazabilidad.
- `docs/09_calidad`: pruebas y criterios de aceptacion.
- `docs/10_gestion`: roadmap, entregables y control de cambios.
- `docs/11_informes`: catalogo y formatos de salida.
- `docs/12_ia`: diseno de proveedores y orquestacion.
- `docs/13_operacion`: manuales operativos.
- `docs/14_legal_funcional`: alineacion con Unidad 8.

## Convencion
Todos los documentos Markdown de esta base se crean en UTF-8 con BOM para compatibilidad con Windows PowerShell y editores comunes en entorno Windows.
"@

$files['docs/00_gobierno/ALCANCE_PROYECTO.md'] = @"
# Alcance del proyecto

**Documento vivo**. Actualizar cuando una decision formal amplie, restrinja o modifique el alcance.

| Campo | Valor |
|---|---|
| Ultima revision | (completar) |
| Responsable | (completar) |
| Estado | Vigente |

## Proposito
Definir el alcance funcional, tecnico y operativo del proyecto LexPenal para evitar desviaciones durante el desarrollo.

## Incluye
- Gestion de casos.
- Gestion basica de clientes vinculados al caso.
- Herramientas operativas derivadas de la Unidad 8.
- Roles de estudiante, supervisor y administrador.
- Checklist vinculante.
- Revision de supervisor.
- Informes exportables.
- Modulo de IA desacoplado.
- Despliegue inicial en maquina virtual.

## Excluye en fase inicial
- Facturacion.
- Contabilidad.
- Aplicacion movil nativa.
- Firma electronica avanzada.
- Integraciones externas no esenciales.

## Criterios globales de exito
- Trazabilidad del caso.
- Coherencia con Unidad 8.
- Control de calidad real.
- Seguridad basica operativa.
- Documentacion suficiente para relevo tecnico.
"@

$files['docs/00_gobierno/DECISIONES_DE_ARQUITECTURA.md'] = @"
# Decisiones de arquitectura

Este documento funciona como indice maestro de Architecture Decision Records (ADR).

| ID | Titulo | Dominio | Estado | Archivo |
|---|---|---|---|---|
| ADR-001 | Despliegue inicial en una VM | Infraestructura | Aprobado | `docs/00_gobierno/adrs/ADR-001-despliegue-inicial-vm.md` |
| ADR-002 | Base de datos relacional PostgreSQL | Datos | Aprobado | `docs/00_gobierno/adrs/ADR-002-postgresql-como-base-relacional.md` |
| ADR-003 | Checklist vinculante como compuerta funcional | Producto | Aprobado | `docs/00_gobierno/adrs/ADR-003-checklist-vinculante.md` |
| ADR-004 | Modulo de IA desacoplado por proveedor | IA | Aprobado | `docs/00_gobierno/adrs/ADR-004-modulo-ia-desacoplado.md` |
| ADR-005 | Informes como salida central del sistema | Producto | Aprobado | `docs/00_gobierno/adrs/ADR-005-informes-como-salida-central.md` |

## Regla
Toda decision tecnica relevante debe registrarse mediante un ADR nuevo o una actualizacion formal del ADR correspondiente.
"@

$files['docs/00_gobierno/adrs/ADR-001-despliegue-inicial-vm.md'] = @"
# ADR-001: Despliegue inicial en una VM

- Estado: Aprobado
- Fecha: (completar)

## Contexto
Se requiere una base controlada para desplegar el MVP sin depender de varios servicios externos desde el inicio.

## Decision
El despliegue inicial vivira en una maquina virtual Linux del servidor, con servicios separados por contenedor.

## Consecuencias
- Menor complejidad inicial.
- Mayor control del entorno.
- Escalabilidad moderada en la primera fase.
"@

$files['docs/00_gobierno/adrs/ADR-002-postgresql-como-base-relacional.md'] = @"
# ADR-002: PostgreSQL como base relacional

- Estado: Aprobado
- Fecha: (completar)

## Contexto
El sistema requiere integridad referencial, trazabilidad, filtros y relaciones entre casos, usuarios, tareas, riesgos y documentos.

## Decision
Usar PostgreSQL como base de datos principal.

## Consecuencias
- Modelo robusto y transaccional.
- Facilidad para auditoria y consultas complejas.
"@

$files['docs/00_gobierno/adrs/ADR-003-checklist-vinculante.md'] = @"
# ADR-003: Checklist vinculante como compuerta funcional

- Estado: Aprobado
- Fecha: (completar)

## Contexto
La Unidad 8 exige que el checklist no sea decorativo sino un control real de avance y validez.

## Decision
El checklist sera vinculante: bloqueara estados del caso y condicionara la conclusion operativa cuando existan bloques incompletos.

## Consecuencias
- Mayor coherencia metodologica.
- Necesidad de reglas de validacion claras.
"@

$files['docs/00_gobierno/adrs/ADR-004-modulo-ia-desacoplado.md'] = @"
# ADR-004: Modulo de IA desacoplado por proveedor

- Estado: Aprobado
- Fecha: (completar)

## Contexto
Se desea usar un proveedor por defecto y permitir proveedores alternos en el futuro sin reescribir el producto.

## Decision
La IA se implementara mediante una capa de abstraccion con proveedores configurables y respuesta normalizada.

## Consecuencias
- Flexibilidad tecnica.
- Mayor trabajo de orquestacion y trazabilidad.
"@

$files['docs/00_gobierno/adrs/ADR-005-informes-como-salida-central.md'] = @"
# ADR-005: Informes como salida central del sistema

- Estado: Aprobado
- Fecha: (completar)

## Contexto
LexPenal debe producir valor visible mediante salidas utiles, no solo formularios.

## Decision
El sistema incorporara desde el MVP informes operativos, juridicos y de supervision exportables.

## Consecuencias
- Requiere motor de plantillas y exportacion.
- Aumenta utilidad practica del sistema.
"@

$files['docs/01_producto/VISION_PRODUCTO.md'] = @"
# Vision del producto

## Proposito
LexPenal es un sistema de gestion de casos de defensa penal colombiana que convierte la metodologia de la Unidad 8 en flujo digital verificable.

## Problema que resuelve
Dispersar el analisis en documentos sueltos, perder trazabilidad, omitir controles de calidad y dificultar la supervision del caso.

## Propuesta de valor
- Caso como centro de trabajo.
- Herramientas metodologicas integradas.
- Checklist vinculante.
- Informes listos para uso real.
- IA seleccionable como apoyo, no como nucleo.
"@

$files['docs/01_producto/BACKLOG_INICIAL.md'] = @"
# Backlog inicial

## Prioridad alta
- Autenticacion y roles.
- Estados del caso.
- Checklist vinculante.
- Revision de supervisor.
- Informes base.
- Backend y persistencia real.

## Prioridad media
- Repositorio documental.
- Agenda de actuaciones y vencimientos.
- Matriz de riesgos con tareas.
- Generacion asistida de conclusion operativa.

## Prioridad posterior
- Preferencias avanzadas por proveedor de IA.
- Modo multi-organizacion.
- Analitica avanzada.
"@

$files['docs/02_arquitectura/ARQUITECTURA_GENERAL.md'] = @"
# Arquitectura general

## Capas
1. Frontend web.
2. Backend API.
3. Base de datos relacional.
4. Almacenamiento documental.
5. Motor de informes.
6. Orquestador de IA.

## Principio
El frontend no contiene la logica critica del negocio. El backend gobierna autenticacion, autorizacion, flujos, validaciones y trazabilidad.
"@

$files['docs/03_datos/MODELO_DATOS.md'] = @"
# Modelo de datos

## Entidades base
- Usuario
- Rol
- Cliente
- Caso
- EstadoCaso
- Hecho
- Prueba
- Riesgo
- Estrategia
- Actuacion
- Tarea
- Documento
- Checklist
- RevisionSupervisor
- ConclusionOperativa
- AIRequestLog

## Regla
Toda entidad critica debe tener trazabilidad minima: fecha de creacion, fecha de actualizacion, usuario creador, usuario modificador y estado.
"@

$files['docs/04_api/CONTRATO_API.md'] = @"
# Contrato API

## Convencion inicial
- Base path: `/api/v1`
- Respuesta JSON estandarizada.
- Autenticacion por token o sesion segura.

## Recursos esperados
- `/auth`
- `/users`
- `/clients`
- `/cases`
- `/cases/{id}/facts`
- `/cases/{id}/evidence`
- `/cases/{id}/risks`
- `/cases/{id}/strategy`
- `/cases/{id}/client-briefing`
- `/cases/{id}/checklist`
- `/cases/{id}/conclusion`
- `/cases/{id}/reports`
- `/ai`
"@

$files['docs/05_frontend/GUIA_FRONTEND.md'] = @"
# Guia frontend

## Principios
- Navegacion centrada en el caso.
- Barra lateral por herramientas.
- Estado visible del checklist.
- Diferenciacion clara por rol.
- Formularios con guardado controlado y validaciones.
"@

$files['docs/06_backend/GUIA_BACKEND.md'] = @"
# Guia backend

## Responsabilidades
- Reglas de negocio.
- Seguridad y permisos.
- Persistencia.
- Auditoria.
- Motor de informes.
- Integracion con IA.
- Validacion del checklist vinculante.
"@

$files['docs/07_infraestructura/DESPLIEGUE_VM.md'] = @"
# Despliegue en VM

## Objetivo
Desplegar el MVP en una maquina virtual Linux controlada por el proyecto.

## Componentes sugeridos
- Nginx
- Backend API
- Frontend compilado
- PostgreSQL
- Worker
- Almacenamiento persistente

## Requisitos
- Backups
- Logs
- SSL
- Firewall
- Snapshot previo a cambios mayores
"@

$files['docs/08_seguridad/SEGURIDAD_BASE.md'] = @"
# Seguridad base

## Controles minimos
- Autenticacion real.
- Autorizacion por rol.
- Registro de auditoria.
- Respaldo de base de datos.
- Respaldo documental.
- Proteccion de secretos.
- Acceso a IA solo via backend.
"@

$files['docs/09_calidad/PLAN_CALIDAD.md'] = @"
# Plan de calidad

## Tipos de prueba
- Unitarias
- Integracion
- E2E
- Validacion juridico-funcional

## Regla critica
Toda prueba de aceptacion funcional relacionada con Unidad 8 debe validar el comportamiento del checklist vinculante.
"@

$files['docs/10_gestion/ROADMAP.md'] = @"
# Roadmap

## Fase 1
Base documental, arquitectura, backlog y definicion funcional.

## Fase 2
Backend, autenticacion, roles y persistencia.

## Fase 3
Herramientas operativas y checklist vinculante.

## Fase 4
Informes y revision de supervisor.

## Fase 5
Modulo IA desacoplado.
"@

$files['docs/11_informes/CATALOGO_INFORMES.md'] = @"
# Catalogo de informes

## Informes MVP
- Resumen ejecutivo del caso.
- Conclusion operativa.
- Informe de control de calidad.
- Informe de riesgos.
- Informe cronologico del caso.
- Informe de revision del supervisor.
- Informe de agenda y vencimientos.

## Formatos esperados
- PDF
- DOCX
- Vista web
"@

$files['docs/12_ia/MODULO_IA.md'] = @"
# Modulo IA

## Objetivo
Permitir proveedor por defecto y proveedores alternativos mediante una capa de abstraccion.

## Componentes sugeridos
- AIProvider
- AIOrchestrator
- PromptTemplates
- ModelSettings
- AIRequestLog

## Regla
Ninguna llamada de IA debe salir directo desde el frontend en produccion.
"@

$files['docs/13_operacion/MANUAL_OPERATIVO.md'] = @"
# Manual operativo

## Temas iniciales
- Alta de usuario.
- Asignacion de caso.
- Revision de supervisor.
- Generacion de informes.
- Procedimiento de respaldo.
- Procedimiento de restauracion.
"@

$files['docs/14_legal_funcional/TRAZABILIDAD_U008.md'] = @"
# Trazabilidad — Unidad 8 del Manual

**Documento vivo**. Actualizar cada vez que se incorpore, modifique o elimine una herramienta del sistema.

| Campo | Valor |
|---|---|
| Ultima revision | (completar) |
| Responsable | (completar) |

## Proposito
Registrar el origen de cada herramienta del sistema en la Unidad 8 del Manual de Defensa Penal Colombiana.
Permite verificar que ningun elemento funcional fue introducido sin respaldo metodologico.

## Tabla de trazabilidad

| Herramienta del sistema | Apartado U008 | Funcion en el metodo | Modulo de software | Observaciones |
|---|---|---|---|---|
| Ficha basica del caso | Apartado 1 | (completar) | (completar) | |
| Matriz de hechos | Apartado 2 | (completar) | (completar) | |
| Matriz probatoria | Apartado 3 | (completar) | (completar) | |
| Matriz de riesgos | Apartado 4 | (completar) | (completar) | |
| Estrategia de defensa | Apartado 5 | (completar) | (completar) | |
| Explicacion al cliente | Apartado 6 | (completar) | (completar) | |
| Checklist de control de calidad | Apartado 7 | (completar) | (completar) | |
| Conclusion operativa | Apartado 8 | (completar) | (completar) | |

## Herramientas extendidas o nuevas
Registrar aqui toda herramienta que no tenga origen directo en la Unidad 8, con justificacion formal.

| Herramienta | Justificacion de inclusion | Aprobado por | Fecha |
|---|---|---|---|
| (completar) | (completar) | (completar) | (completar) |

## Regla de trazabilidad
Todo cambio tecnico que impacte herramienta, flujo, checklist o conclusion debe contrastarse contra este documento antes de implementarse.
Si no hay apartado de la U008 que respalde el cambio, se requiere justificacion formal en la columna de observaciones.
"@

$files['docs/14_legal_funcional/REGLAS_FUNCIONALES_VINCULANTES.md'] = @"
# Reglas funcionales vinculantes

**Documento de gobierno**. Ninguna decision tecnica puede ignorar estas reglas sin una ADR que las modifique formalmente.

| Campo | Valor |
|---|---|
| Ultima revision | (completar) |
| Responsable | (completar) |

## Formato de cada regla
Cada regla debe incluir: identificador, enunciado, consecuencias tecnicas y ADR asociada si aplica.

---

## R01 — El caso es la unidad central del sistema
**Enunciado**: (completar — ejemplo: toda entidad critica del sistema pertenece a un caso)
**Consecuencias tecnicas**: (completar)
**ADR asociada**: (completar o N/A)

## R02 — El checklist es vinculante
**Enunciado**: (completar — el estado del checklist condiciona el avance del caso)
**Consecuencias tecnicas**: (completar — que estados bloquea, que valida el backend)
**ADR asociada**: ADR-003

## R03 — La conclusion operativa es un entregable formal
**Enunciado**: (completar — estructura obligatoria, dependencia del checklist)
**Consecuencias tecnicas**: (completar)
**ADR asociada**: (completar o N/A)

## R04 — La revision del supervisor es un paso formal del flujo
**Enunciado**: (completar — cuando aplica, que bloquea, que habilita)
**Consecuencias tecnicas**: (completar — restriccion en backend, no solo advertencia en frontend)
**ADR asociada**: (completar o N/A)

## R05 — La IA es un asistente, no un decisor
**Enunciado**: (completar — que puede y que no puede hacer el modulo de IA)
**Consecuencias tecnicas**: (completar — registro obligatorio, sin escritura directa al caso)
**ADR asociada**: ADR-004

## R06 — Toda accion critica es auditable
**Enunciado**: (completar — que acciones entran en la bitacora)
**Consecuencias tecnicas**: (completar — entidad EventoAuditoria, campos minimos)
**ADR asociada**: (completar o N/A)

## R07 — El modulo de IA es desacoplado por proveedor
**Enunciado**: (completar — configurabilidad, sin dependencia de proveedor unico)
**Consecuencias tecnicas**: (completar — capa de abstraccion, proveedor por defecto)
**ADR asociada**: ADR-004

## Reglas adicionales
Agregar aqui reglas nuevas siguiendo el mismo formato.
"@

$files['docs/14_legal_funcional/MATRIZ_REQUISITOS_U008_A_MODULOS.md'] = @"
# Matriz de requisitos — Unidad 8 a modulos del sistema

**Documento de referencia** para diseno de backend, modelo de datos y criterios de aceptacion.
Completar una fila por cada herramienta antes de iniciar el desarrollo del modulo correspondiente.

| Campo | Valor |
|---|---|
| Ultima revision | (completar) |
| Responsable | (completar) |

## Formato de cada entrada
- **Origen**: apartado de la Unidad 8
- **Requisito funcional**: que debe poder hacer el sistema
- **Modulo del sistema**: donde vive la implementacion
- **Entidades de datos**: entidades del modelo involucradas
- **Restriccion vinculante**: regla de REGLAS_FUNCIONALES_VINCULANTES.md asociada
- **Criterio de aceptacion clave**: como se verifica que el modulo hace lo que el metodo exige

---

### Ficha basica del caso
- **Origen**: Apartado 1, U008
- **Requisito funcional**: (completar)
- **Modulo del sistema**: (completar)
- **Entidades de datos**: (completar)
- **Restriccion vinculante**: R01
- **Criterio de aceptacion clave**: (completar)

### Matriz de hechos
- **Origen**: Apartado 2, U008
- **Requisito funcional**: (completar)
- **Modulo del sistema**: (completar)
- **Entidades de datos**: (completar)
- **Restriccion vinculante**: R01
- **Criterio de aceptacion clave**: (completar)

### Matriz probatoria
- **Origen**: Apartado 3, U008
- **Requisito funcional**: (completar)
- **Modulo del sistema**: (completar)
- **Entidades de datos**: (completar)
- **Restriccion vinculante**: R01
- **Criterio de aceptacion clave**: (completar)

### Matriz de riesgos
- **Origen**: Apartado 4, U008
- **Requisito funcional**: (completar)
- **Modulo del sistema**: (completar)
- **Entidades de datos**: (completar)
- **Restriccion vinculante**: R01
- **Criterio de aceptacion clave**: (completar)

### Estrategia de defensa
- **Origen**: Apartado 5, U008
- **Requisito funcional**: (completar)
- **Modulo del sistema**: (completar)
- **Entidades de datos**: (completar)
- **Restriccion vinculante**: R01
- **Criterio de aceptacion clave**: (completar)

### Explicacion al cliente
- **Origen**: Apartado 6, U008
- **Requisito funcional**: (completar)
- **Modulo del sistema**: (completar)
- **Entidades de datos**: (completar)
- **Restriccion vinculante**: R01
- **Criterio de aceptacion clave**: (completar)

### Checklist de control de calidad
- **Origen**: Apartado 7, U008
- **Requisito funcional**: (completar)
- **Modulo del sistema**: (completar)
- **Entidades de datos**: (completar)
- **Restriccion vinculante**: R01, R02
- **Criterio de aceptacion clave**: (completar)

### Conclusion operativa
- **Origen**: Apartado 8, U008
- **Requisito funcional**: (completar)
- **Modulo del sistema**: (completar)
- **Entidades de datos**: (completar)
- **Restriccion vinculante**: R01, R02, R03, R04
- **Criterio de aceptacion clave**: (completar)
"@

$files['docs/14_legal_funcional/CRITERIOS_DE_ACEPTACION_JURIDICO_FUNCIONALES.md'] = @"
# Criterios de aceptacion juridico-funcionales

**Documento de QA funcional**. Completar antes de iniciar pruebas de cada modulo.
Cada criterio debe poder responderse con SI o NO sin ambiguedad.

| Campo | Valor |
|---|---|
| Ultima revision | (completar) |
| Responsable QA | (completar) |

## Formato de cada criterio
- Descripcion del comportamiento esperado
- Condicion de verificacion (como se prueba)
- Estado: pendiente / verificado / fallido

---

## Ficha basica del caso
- [ ] (completar — ejemplo: el sistema permite registrar todos los campos del Apartado 1)
- Condicion: (completar)
- [ ] (completar)
- Condicion: (completar)

## Matriz de hechos
- [ ] (completar)
- Condicion: (completar)
- [ ] (completar)
- Condicion: (completar)

## Matriz probatoria
- [ ] (completar)
- Condicion: (completar)
- [ ] (completar)
- Condicion: (completar)

## Matriz de riesgos
- [ ] (completar)
- Condicion: (completar)
- [ ] (completar)
- Condicion: (completar)

## Estrategia de defensa
- [ ] (completar)
- Condicion: (completar)

## Explicacion al cliente
- [ ] (completar)
- Condicion: (completar)

## Checklist de control de calidad
- [ ] El avance a estado pendiente_revision requiere checklist sin bloques criticos incompletos (R02)
- Condicion: (completar — intentar transicion con bloque incompleto y verificar bloqueo en backend)
- [ ] (completar)
- Condicion: (completar)

## Conclusion operativa
- [ ] La conclusion no puede marcarse como lista para cliente sin revision formal del supervisor (R03, R04)
- Condicion: (completar — intentar marcar sin revision y verificar bloqueo)
- [ ] (completar)
- Condicion: (completar)

## Criterios transversales — Modulo de IA
- [ ] Toda llamada al modulo de IA queda registrada en el log (R05, R06)
- Condicion: (completar)
- [ ] La respuesta de IA no modifica directamente ningun campo del caso (R05)
- Condicion: (completar)
- [ ] El proveedor de IA es configurable sin cambiar codigo de la aplicacion (R07)
- Condicion: (completar)

## Criterio transversal — Auditoria
- [ ] Las acciones criticas del caso quedan registradas con usuario, fecha y accion (R06)
- Condicion: (completar)
"@

$files['src/.gitkeep'] = "# placeholder`n"
$files['src/frontend/.gitkeep'] = "# placeholder`n"
$files['src/backend/.gitkeep'] = "# placeholder`n"
$files['src/shared/.gitkeep'] = "# placeholder`n"
$files['infra/.gitkeep'] = "# placeholder`n"
$files['scripts/.gitkeep'] = "# placeholder`n"
$files['tests/.gitkeep'] = "# placeholder`n"
$files['resources/.gitkeep'] = "# placeholder`n"

foreach ($relativePath in $files.Keys) {
    $fullPath = Join-Path $BasePath $relativePath
    Write-Utf8BomFile -Path $fullPath -Content $files[$relativePath] -ForceWrite:$Force
}

Write-Host ""
Write-Host "Estructura base de LexPenal generada en:" -ForegroundColor Green
Write-Host $BasePath -ForegroundColor Green
