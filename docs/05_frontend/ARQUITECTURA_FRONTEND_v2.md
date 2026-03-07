# Arquitectura de frontend

Documento de referencia de la arquitectura del frontend de LexPenal.
Define stack, capas, patrones, sistema de diseño, comunicación con el backend
y reglas de implementación.

**Documentos relacionados**
- `docs/00_gobierno/adrs/ADR-003-maquina-de-estados-del-caso.md`
- `docs/01_producto/ROLES_Y_PERMISOS.md`
- `docs/01_producto/ESTADOS_DEL_CASO.md`
- `docs/04_api/CONTRATO_API.md`
- `docs/06_backend/ARQUITECTURA_BACKEND.md`

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Alcance de este documento

Este documento cubre la arquitectura de frontend a nivel estratégico:
stack, capas, sistema de diseño, gestión de estado, comunicación con la API,
manejo de autenticación y reglas de implementación.

El detalle de componentes individuales, pantallas y flujos de navegación
se desarrollarán en documentos separados cuando el proyecto lo requiera:
- `COMPONENTES_FRONTEND.md` — catálogo y especificación de componentes.
- `FLUJOS_NAVEGACION.md` — rutas, transiciones y flujos por perfil.
- `SISTEMA_DISENO.md` — tokens, tipografía, paleta y guía de estilo completa.

---

## Stack tecnológico

| Componente | Decisión |
|---|---|
| Lenguaje | TypeScript |
| Framework | React 18 |
| Metaframework | Next.js (App Router) |
| Estilos | Tailwind CSS + CSS variables para tokens de diseño |
| Gestión de estado global | Zustand — (confirmar antes de iniciar) |
| Gestión de estado servidor | TanStack Query (React Query) |
| Cliente HTTP | Fetch nativo con wrapper tipado — sin Axios |
| Formularios | React Hook Form + Zod para validación |
| Generación de PDF/DOCX | Delegado al backend — el frontend solo descarga |
| Testing | Vitest + Testing Library |
| Gestor de paquetes | npm |

**Next.js con App Router es la decisión firme del proyecto.**
Permite SSR selectivo, protección de rutas mediante middleware y separación
clara entre Server Components y Client Components, lo que es relevante
dado el esquema de autenticación híbrido adoptado.
No se contempla migración a Vite u otro bundler salvo decisión formal
documentada en una ADR con justificación técnica explícita.

---

## Principios de diseño de frontend

**PF-01 — El frontend no tiene lógica de negocio.**
La autorización, validación de estado del caso y reglas de guardia
las define el backend. El frontend refleja el estado; no lo gobierna.
Las validaciones del frontend son orientativas para UX; nunca son autoritativas.

**PF-02 — Lo que no está disponible no se muestra.**
Las acciones a las que el usuario no tiene acceso (por perfil o por estado del caso)
no se deshabilitan — directamente no se renderizan.
Un botón deshabilitado sugiere que la acción existe pero no es posible ahora.
Un botón ausente comunica que esa acción no forma parte del flujo actual.

**PF-03 — El estado del caso gobierna la interfaz.**
Cada vista del expediente renderiza en función del `estado_actual` del caso
y del perfil del usuario en sesión. No hay lógica adicional de "modo edición"
separada del estado: si el caso está en `en_analisis`, se puede editar;
si está en `pendiente_revision`, no.

**PF-04 — La interfaz es un reflejo fiel del expediente.**
El diseño visual comunica con claridad el estado procesal del caso.
Los estados `devuelto` y `aprobado_supervisor` son visualmente diferenciados
en el dashboard. Un estudiante que entra al sistema debe saber de inmediato
qué casos requieren su atención.

**PF-05 — La respuesta del backend es la fuente de verdad.**
El frontend optimista puede anticipar cambios en pantalla, pero siempre
reconcilia con la respuesta del servidor. En caso de conflicto, gana el backend.

**PF-06 — La IA es asistencia visible, no integración invisible.**
El módulo de IA tiene un panel propio y claramente delimitado en cada herramienta.
El usuario sabe siempre que está interactuando con un asistente, no con el sistema.
La respuesta de la IA nunca aparece directamente en los campos del formulario.

---

## Sistema de diseño

### Identidad visual

LexPenal opera en el ámbito del derecho penal colombiano — un entorno de alta
responsabilidad, documento denso y perfil profesional. La identidad visual
comunica: rigor, claridad y confianza institucional.

**Dirección estética**: refinada, oscura, con acento dorado.
Influenciada por la estética editorial jurídica y los sistemas de gestión
documental de alto estándar. No es una app de consumo: es una herramienta
profesional para consultorio jurídico.

### Tokens de diseño

```css
/* Fondos */
--color-bg:           #0B1622;   /* fondo base */
--color-surface:      #111D2C;   /* superficies elevadas */
--color-card:         #172336;   /* tarjetas y paneles */
--color-border:       #1F3048;   /* bordes y separadores */

/* Texto */
--color-text:         #DDD5C4;   /* texto principal */
--color-muted:        #6B8099;   /* texto secundario */

/* Acento */
--color-accent:       #BF9840;   /* dorado — acción principal */
--color-accent-light: rgba(191, 152, 64, 0.12);

/* Estados semánticos */
--color-success:      #3A9E6F;
--color-danger:       #A63B3B;
--color-info:         #2E74B5;

/* Perfiles */
--color-estudiante:   #2E74B5;
--color-supervisor:   #BF9840;
--color-admin:        #7B5EA7;

/* Estados del caso */
--color-borrador:           #6B8099;
--color-en-analisis:        #2E74B5;
--color-pendiente-revision: #BF9840;
--color-devuelto:           #A63B3B;
--color-aprobado-supervisor:#3A9E6F;
--color-listo-cliente:      #7B5EA7;
--color-cerrado:            #3A4A5C;
```

### Tipografía

| Uso | Fuente | Peso |
|---|---|---|
| Títulos y encabezados | Playfair Display | 400, 500, 600, 700 |
| Cuerpo y UI | Source Sans 3 | 300, 400, 500, 600 |
| Código y radicados | JetBrains Mono | 400 |

### Estados visuales del caso

Cada estado del caso tiene color, etiqueta y comportamiento de interfaz diferenciados.
Esta tabla es la referencia de renderizado:

| Estado | Color token | Etiqueta visible | Edición |
|---|---|---|---|
| `borrador` | `--color-borrador` | Borrador | ✅ |
| `en_analisis` | `--color-en-analisis` | En análisis | ✅ |
| `pendiente_revision` | `--color-pendiente-revision` | Pendiente revisión | ❌ |
| `devuelto` | `--color-devuelto` | Devuelto | ✅ |
| `aprobado_supervisor` | `--color-aprobado-supervisor` | Aprobado | ❌ |
| `listo_para_cliente` | `--color-listo-cliente` | Listo para cliente | ❌ |
| `cerrado` | `--color-cerrado` | Cerrado | ❌ |

---

## Capas de la aplicación

```
┌─────────────────────────────────────────────┐
│              Capa de páginas                │  ← Next.js App Router pages
│              (app/ directory)               │     Rutas y layouts por perfil
├─────────────────────────────────────────────┤
│            Capa de componentes              │  ← Componentes React
│            (components/)                   │     UI agnóstica de datos
│                                             │     Composición por perfil y estado
├─────────────────────────────────────────────┤
│            Capa de estado y datos           │  ← Zustand (estado global UI)
│            (store/ + hooks/)               │     TanStack Query (datos servidor)
│                                             │     Custom hooks por dominio
├─────────────────────────────────────────────┤
│            Capa de API client               │  ← Wrapper tipado sobre HTTP
│            (lib/api/)                      │     Interceptores de autenticación
│                                             │     Manejo centralizado de errores
└─────────────────────────────────────────────┘
```

### Reglas entre capas

- Las páginas componen layouts y cargan datos vía hooks. No tienen lógica de negocio.
- Los componentes son agnósticos del origen de los datos. Reciben props; no llaman a la API directamente.
- Los hooks encapsulan toda la comunicación con la API y el estado derivado.
- El cliente de API es el único que conoce las URLs, headers y formato de error del backend.

---

## Gestión de estado

### Estado de servidor — TanStack Query

Todo dato que proviene del backend se gestiona con TanStack Query.
Esto incluye: usuario en sesión, lista de casos, detalle del caso,
herramientas operativas, checklist, revisión del supervisor e informes.

Beneficios para LexPenal:
- Caché automática con invalidación selectiva al mutar.
- Revalidación en foco de ventana — el dashboard siempre muestra el estado real.
- Estados de carga y error manejados de forma consistente.

Convención de naming de queries:
```typescript
// Claves de query organizadas por recurso
const queryKeys = {
  casos:     {
    list:   (filtros) => ['casos', 'list', filtros],
    detail: (id)      => ['casos', 'detail', id],
  },
  checklist: (caso_id) => ['checklist', caso_id],
  revision:  (caso_id) => ['revision', caso_id],
}
```

### Estado de UI — Zustand

Estado de interfaz que no proviene del servidor.
Zustand es estado de conveniencia para la UI — no es la fuente de continuidad
de sesión. La sesión persiste mediante cookie HttpOnly gestionada por el servidor.
Zustand se rehidrata desde el backend al recargar la aplicación.

Contenido del store:
- perfil y nombre del usuario autenticado (rehidratado tras login o recarga).
- panel de IA abierto/cerrado.
- herramienta activa dentro del expediente.
- notificaciones y alertas transitorias.

Lo que **no** vive en Zustand:
- el token de acceso Bearer (vive en memoria de sesión controlada, no en store persistido).
- decisiones de autorización (las toma el backend; el frontend solo refleja).

---

## Autenticación

Se adopta un esquema híbrido explícito con dos mecanismos diferenciados
según el contexto de ejecución.

**Contexto servidor (Next.js middleware y Server Components)**
La cookie HttpOnly gestiona la validación inicial de sesión, la protección
de rutas y la carga del shell de la aplicación (layout y navegación).
El middleware de Next.js lee esta cookie para decidir si el usuario puede
acceder a una ruta protegida sin exponer el token al cliente.

**Contexto cliente (Client Components)**
Las llamadas HTTP al backend desde Client Components se autentican mediante
Bearer token en el header `Authorization`. Este token se obtiene en el flujo
de login y se conserva en memoria de sesión — no se persiste en localStorage
ni se deriva de la cookie HttpOnly.

**Regla crítica**: la cookie HttpOnly es usada por el navegador automáticamente
en contexto servidor. No es legible desde JavaScript cliente. El cliente
no puede ni debe intentar leer la cookie para obtener el Bearer.

**Flujo de autenticación completo:**

```
1. Usuario accede a ruta protegida
   └─ middleware Next.js verifica cookie HttpOnly
   └─ sin cookie válida → redirige a /login

2. Login exitoso
   └─ backend retorna:
       - cookie HttpOnly (sesión SSR — la establece el servidor)
       - token de acceso en body (Bearer para llamadas cliente)
   └─ token de acceso → guardado en memoria de sesión (no en cookie, no en localStorage)
   └─ perfil del usuario → guardado en store Zustand
   └─ redirección a /dashboard

3. Llamadas desde Client Components
   └─ cliente Fetch inyecta header Authorization: Bearer {token} automáticamente

4. Recarga de página
   └─ cookie HttpOnly persiste en navegador
   └─ middleware valida sesión → permite acceso al shell
   └─ primer Client Component rehidrata token y perfil desde endpoint de sesión
   └─ /api/v1/auth/session retorna { token_acceso, usuario } usando la cookie

5. Token expirado o inválido (401 desde backend)
   └─ cliente Fetch limpia token en memoria y store
   └─ redirige a /login con mensaje de sesión expirada
```

---

## SSR y datos sensibles

**Estrategia de rendering adoptada**: Server Components para layout, shell y
navegación; Client Components para todos los datos operativos del caso.

| Tipo de contenido | Contexto de rendering | Justificación |
|---|---|---|
| Shell de la app (sidebar, header, layout) | Server Component | No contiene datos sensibles; se beneficia del SSR |
| Autenticación y protección de rutas | Middleware servidor | La cookie HttpOnly solo es accesible en contexto servidor |
| Lista de casos | Client Component | Requiere Bearer; se cachea con TanStack Query |
| Detalle del caso y herramientas operativas | Client Component | Datos jurídicamente sensibles; no deben aparecer en HTML inicial |
| Checklist, revisión, conclusión | Client Component | Ídem |
| Módulo de IA | Client Component | Interactivo por naturaleza |

**Regla de datos sensibles en SSR**:
Los datos operativos del expediente (hechos, pruebas, riesgos, estrategia,
conclusión operativa) no se cargan en Server Components ni aparecen en el
HTML generado por el servidor. Se cargan exclusivamente desde Client Components
usando el Bearer token, después de que la aplicación está hidratada en el cliente.
Esto protege el contenido jurídicamente sensible de quedar expuesto en el
HTML inicial de la respuesta servidor, en logs de proxy o en cachés intermedias.

---

### Cliente de API

Un wrapper tipado centraliza toda comunicación con el backend:

```typescript
// lib/api/client.ts — estructura conceptual
const apiClient = {
  get:    <T>(url, params?)  => fetch con token + manejo de error
  post:   <T>(url, body?)    => fetch con token + manejo de error
  put:    <T>(url, body?)    => fetch con token + manejo de error
  delete: <T>(url)           => fetch con token + manejo de error
}
```

### Manejo de errores HTTP

El cliente convierte los códigos de respuesta del backend en errores tipados:

| Código | Error en cliente | Comportamiento UI |
|---|---|---|
| `400` | `ValidationError` | Muestra errores por campo en el formulario |
| `401` | `AuthError` | Limpia sesión, redirige a login |
| `403` | `ForbiddenError` | Muestra mensaje de acceso denegado |
| `404` | `NotFoundError` | Redirige a página 404 |
| `409` | `ConflictError` | Muestra estado actual del caso, sugiere recargar |
| `422` | `BusinessRuleError` | Muestra lista de motivos del rechazo |
| `503` | `ServiceUnavailableError` | Muestra aviso de IA no disponible; no bloquea flujo |
| `500` | `ServerError` | Muestra error genérico; loguea en consola |

### Invalidación de caché tras mutaciones

Al ejecutar operaciones que modifican el estado del servidor, se invalidan
las queries afectadas:

| Mutación | Queries a invalidar |
|---|---|
| Transición de estado | `casos.detail(id)`, `casos.list(*)` |
| Guardar herramienta | `herramienta.detail(caso_id)`, `checklist(caso_id)` |
| Registrar revisión | `revision(caso_id)`, `casos.detail(id)` |
| Generar informe | `informes(caso_id)` |

---

## Renderizado por perfil y estado

### Principio de renderizado condicional

```
Para cada acción visible en pantalla:
  si (perfil_tiene_permiso(accion) && estado_permite(accion)):
    renderizar el componente
  sino:
    no renderizar nada
```

No usar `disabled`, `opacity: 0.5` ni `pointer-events: none` como sustituto
de no-renderizado. Estas técnicas dejan la acción visible y comunican
"puedes pero no ahora", que no es el mensaje correcto.

### Hook de permisos

Un hook centraliza la lógica de visibilidad por perfil y estado:

```typescript
// hooks/usePermisos.ts — estructura conceptual
function usePermisos(caso?: Caso) {
  const { perfil } = useUsuario();
  return {
    puedeEditar:          puedeEditar(perfil, caso?.estado_actual),
    puedeEnviarRevision:  puedeEnviar(perfil, caso?.estado_actual),
    puedeAprobar:         puedeAprobar(perfil, caso?.estado_actual),
    puedeDevolver:        puedeDevolver(perfil, caso?.estado_actual),
    puedeCerrar:          puedeCerrar(perfil, caso?.estado_actual),
    puedeVerChecklist:    puedeVerChecklist(perfil),
    puedeGestionarUsers:  perfil === 'administrador',
  }
}
```

Este hook es la única fuente de verdad de visibilidad en el frontend.
Ningún componente evalúa permisos directamente.

---

## Estructura de directorios

Referencial y orientada a Next.js con App Router.
Debe revisarse al iniciar el proyecto según convenciones del equipo.

```
src/frontend/
├── app/                         ← Next.js App Router
│   ├── (auth)/
│   │   └── login/
│   ├── dashboard/
│   ├── casos/
│   │   ├── [id]/
│   │   │   ├── ficha/
│   │   │   ├── hechos/
│   │   │   ├── pruebas/
│   │   │   ├── riesgos/
│   │   │   ├── estrategia/
│   │   │   ├── cliente/
│   │   │   ├── checklist/
│   │   │   ├── conclusion/
│   │   │   └── revision/
│   │   └── nuevo/
│   └── admin/
│       ├── usuarios/
│       └── configuracion/
│
├── components/
│   ├── ui/                      ← componentes base (Button, Input, Badge, etc.)
│   ├── caso/                    ← componentes del expediente
│   │   ├── CasoCard
│   │   ├── CasoEstadoBadge
│   │   ├── CasoHeader
│   │   └── TransicionEstado
│   ├── herramientas/            ← componentes de cada herramienta U008
│   │   ├── FichaBasica
│   │   ├── MatrizHechos
│   │   ├── MatrizProbatoria
│   │   ├── MatrizRiesgos
│   │   ├── EstrategiaDefensa
│   │   ├── ExplicacionCliente
│   │   ├── ChecklistCalidad
│   │   └── ConclusionOperativa
│   ├── revision/
│   │   └── RevisionSupervisor
│   ├── ia/
│   │   └── PanelAsistente
│   └── layout/
│       ├── Sidebar
│       ├── Header
│       └── DashboardLayout
│
├── hooks/
│   ├── useUsuario
│   ├── usePermisos              ← única fuente de verdad de visibilidad
│   ├── useCasos
│   ├── useCaso
│   ├── useHerramienta
│   ├── useChecklist
│   ├── useRevision
│   ├── useInformes
│   └── useIA
│
├── store/                       ← Zustand
│   ├── auth.store
│   ├── ui.store
│   └── ia.store
│
├── lib/
│   ├── api/
│   │   ├── client               ← wrapper tipado HTTP
│   │   ├── casos.api
│   │   ├── herramientas.api
│   │   ├── revision.api
│   │   ├── informes.api
│   │   └── ia.api
│   └── utils/
│
└── types/                       ← tipos TypeScript del dominio
    ├── caso.types
    ├── usuario.types
    ├── herramienta.types
    └── api.types
```

---

## Flujo de autenticación y sesión

```
1. Usuario accede a cualquier ruta protegida
   └─ middleware de Next.js verifica cookie de sesión
   └─ si no hay sesión → redirige a /login

2. Login exitoso
   └─ backend retorna { token, usuario: { id, nombre, perfil } }
   └─ token se guarda en cookie HttpOnly (SSR) + store Zustand (cliente)
   └─ perfil se guarda en store Zustand
   └─ redirección a /dashboard

3. En cada solicitud al backend
   └─ cliente API inyecta header Authorization automáticamente

4. Token expirado o inválido (401)
   └─ cliente API limpia store + cookie
   └─ redirige a /login con mensaje de sesión expirada
```

---

## Reglas de implementación transversales

**RF-FRONT-01** — Los componentes no llaman a la API directamente.
Toda comunicación con el backend pasa por un custom hook.
Un componente que importa `apiClient` directamente es una señal de alerta.

**RF-FRONT-02** — El hook `usePermisos` es la única fuente de verdad de visibilidad.
Ningún componente evalúa `perfil === 'supervisor'` o `estado === 'cerrado'`
directamente. Toda lógica de visibilidad se centraliza en `usePermisos`.

**RF-FRONT-03** — Las acciones no disponibles no se renderizan.
No se usan atributos `disabled`, `aria-disabled`, opacidad reducida ni
`pointer-events: none` como sustituto de no-renderizar una acción.
Ver PF-02.

**RF-FRONT-04** — El estado del formulario se invalida al cambiar el estado del caso.
Cuando el caso transiciona de estado, las queries relacionadas se invalidan
y los formularios en pantalla se actualizan. No se deja al usuario editando
un formulario sobre un caso cuyo estado cambió en segundo plano.

**RF-FRONT-05** — Los errores de negocio (`422`) se muestran como lista de motivos.
El componente que ejecuta una transición de estado debe manejar `BusinessRuleError`
y renderizar los motivos del rechazo en un panel visible, no solo en consola.

**RF-FRONT-06** — El panel de IA es un componente separado y siempre identificado.
El asistente de IA tiene su propio panel visual, claramente delimitado del
formulario de la herramienta. Su respuesta no puede fluir a los campos del formulario
por ningún mecanismo automático (paste, fill, etc.).

**RF-FRONT-07** — El progreso del checklist puede calcularse en el cliente cuando los datos ya están disponibles.
Si los datos del checklist están en caché de TanStack Query, el hook `useChecklist`
calcula el porcentaje de progreso localmente sin solicitud adicional al backend.
El backend sigue siendo la fuente de verdad del estado completo del checklist.
Si el backend expone un campo de progreso precalculado por razones de rendimiento,
el frontend usa ese valor en lugar del cálculo local. La regla es de conveniencia,
no una restricción arquitectónica rígida.

**RF-FRONT-08** — La navegación entre herramientas no recarga el caso.
Las ocho herramientas del expediente comparten el mismo layout y el caso
ya está en caché de TanStack Query. Navegar entre herramientas debe ser
instantáneo sin nueva solicitud al endpoint `/api/v1/cases/{id}`.

---

## Accesibilidad y formularios extensos

LexPenal opera con formularios de alta densidad: matrices de hechos, matrices
probatorias, checklist de múltiples bloques y paneles de revisión.
La accesibilidad no es opcional en este contexto — es parte de la usabilidad
profesional del sistema.

Esta sección establece las reglas base. El detalle completo se desarrollará
en `SISTEMA_DISENO.md` cuando el proyecto lo requiera.

**AC-01 — Navegación por teclado completa.**
Todos los formularios, matrices y paneles son navegables con teclado.
Tab, Shift+Tab, Enter y Escape deben funcionar de forma predecible
en todos los componentes interactivos.

**AC-02 — Focus management en transiciones de estado.**
Cuando el caso transiciona de estado (ej. envío a revisión, devolución),
el foco del teclado se mueve al elemento de confirmación o al primer
mensaje de resultado visible. No queda perdido en un elemento oculto.

**AC-03 — Errores de validación asociados al campo.**
Cada error de formulario se asocia al campo que lo originó mediante
`aria-describedby`. El mensaje de error es visible, legible y no depende
solo del color para comunicar el problema.

**AC-04 — Estados del caso comunicados textualmente.**
El color de estado del caso (tokens de diseño) siempre va acompañado de
una etiqueta textual. El estado nunca se comunica solo por color.

**AC-05 — Contraste mínimo en modo oscuro.**
Todos los textos sobre fondos oscuros cumplen ratio de contraste WCAG AA
como mínimo (4.5:1 para texto normal, 3:1 para texto grande).
Los tokens de diseño definidos en este documento deben verificarse
contra este criterio antes de aprobarse para producción.
