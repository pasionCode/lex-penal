# ADR-002 — PostgreSQL como base de datos relacional

| Campo | Valor |
|---|---|
| Estado | **Cerrado** |
| Fecha | 2026-03-06 |
| Decisor | Equipo técnico LexPenal |
| Documentos relacionados | `docs/03_datos/MODELO_DATOS.md`, `docs/03_datos/REGLAS_NEGOCIO.md`, `docs/00_gobierno/adrs/ADR-006-orm-acceso-a-datos.md` |

---

## Contexto

LexPenal gestiona expedientes jurídicos con estructura fuertemente
relacional: un caso contiene hechos, pruebas, riesgos, estrategia,
revisiones, documentos e historial de auditoría. Estas entidades tienen
relaciones explícitas entre sí y están sujetas a reglas de negocio
que exigen integridad referencial, trazabilidad completa y registros
inmutables de auditoría.

Se evalúa qué motor de base de datos respalda mejor estos requisitos
para el MVP.

---

## Opciones evaluadas

### Opción A — PostgreSQL

Base de datos relacional de código abierto, con soporte completo de
transacciones ACID, integridad referencial, restricciones a nivel de
esquema y extensiones avanzadas.

**Ventajas**
- Transacciones ACID completas — críticas para operaciones atómicas
  como transición de estado + registro de auditoría en una sola operación.
- Integridad referencial garantizada por el motor — las relaciones entre
  caso, herramientas, revisiones y auditoría no se pueden romper
  accidentalmente.
- Restricciones a nivel de esquema que refuerzan reglas de negocio:
  campos obligatorios, unicidad de radicado, relaciones obligatorias.
- Soporte nativo de tipos JSON para campos de estructura variable
  puntuales (bloques de conclusión, listas de hechos, riesgos).
  JSON actúa como complemento del modelo relacional — no como
  sustituto. La estructura principal del expediente es relacional
  normalizada; JSON se reserva para campos donde la variabilidad
  interna no justifica tablas adicionales.
- Madurez, estabilidad y documentación amplia.
- Integración consolidada con NestJS vía ORM (TypeORM o Prisma —
  decisión en ADR-006).
- Sin costo de licencia.

**Desventajas**
- Requiere gestión del servidor de base de datos en la VM (ADR-001).
- Las migraciones de esquema deben gestionarse con disciplina —
  cambios de modelo en producción requieren cuidado.

---

### Opción B — MongoDB (NoSQL documental)

Base de datos orientada a documentos. Cada caso podría almacenarse
como un documento JSON con sus herramientas embebidas.

**Ventajas**
- Flexibilidad de esquema — útil cuando la estructura de datos no
  está definida de antemano.
- Modelo de documento puede parecer natural para un expediente.

**Desventajas**
- Sin transacciones ACID completas en el modelo básico — las
  operaciones atómicas entre colecciones son complejas.
- La inmutabilidad de `eventos_auditoria` y `ai_request_log`
  (RN-AUD-02) no puede garantizarse a nivel de motor sin trabajo
  adicional.
- Integridad referencial no gestionada por el motor — queda en
  responsabilidad del código de aplicación, fuente de errores.
- La estructura del expediente de LexPenal está bien definida y es
  estable — la flexibilidad de esquema no aporta valor.

---

### Opción C — SQLite

Base de datos relacional embebida, sin servidor separado.

**Ventajas**
- Sin servidor — extremadamente simple de configurar.
- Adecuada para desarrollo local y pruebas.

**Desventajas**
- Sin soporte real de concurrencia — múltiples usuarios simultáneos
  degradan el rendimiento significativamente.
- No adecuada para producción con datos jurídicos que requieren
  acceso concurrente y backups confiables.
- Limitaciones en tipos de datos y restricciones avanzadas.

---

### Opción D — MySQL / MariaDB

Base de datos relacional ampliamente usada.

**Ventajas**
- Madurez y amplia adopción.
- Soporte de transacciones ACID con InnoDB.

**Desventajas**
- PostgreSQL supera a MySQL en soporte de tipos avanzados (JSON nativo,
  arrays, tipos personalizados) que LexPenal aprovecha para los campos
  de estructura variable.
- PostgreSQL ofrece una combinación más favorable de capacidades
  avanzadas, ecosistema y adecuación al dominio de LexPenal.
- Sin ventaja diferencial que justifique elegirlo sobre PostgreSQL
  para este caso de uso.

---

## Criterios de decisión

| Criterio | PostgreSQL | MongoDB | SQLite | MySQL |
|---|---|---|---|---|
| Transacciones ACID | Completas | Limitadas | Completas | Completas (InnoDB) |
| Integridad referencial | Motor | Aplicación | Motor | Motor |
| Inmutabilidad auditoría | Garantizable | Requiere trabajo | Garantizable | Garantizable |
| Concurrencia en producción | Alta | Alta | Baja | Alta |
| Tipos JSON nativos | Sí | Nativo | No | Limitado |
| Integración NestJS | Madura | Madura | Básica | Madura |
| Adecuación al MVP | Alta | Baja | No | Media |

---

## Decisión

> **[x] Opción A — PostgreSQL**

**Justificación**: El modelo de datos de LexPenal es fuertemente
relacional y las reglas de negocio exigen integridad garantizada por
el motor, no por el código. Las operaciones críticas (transición de
estado + auditoría, registro de revisión + transición) son atómicas
por definición — requieren transacciones ACID reales. La inmutabilidad
de `eventos_auditoria` y `ai_request_log` (RN-AUD-02) se puede
garantizar a nivel de esquema en PostgreSQL. La estructura del
expediente está bien definida y es estable — la flexibilidad de
esquema de MongoDB no aporta valor y elimina garantías que sí
necesitamos.

---

## Consecuencias

- PostgreSQL 16 se instala en la misma VM del sistema (ADR-001).
- El puerto 5432 no se expone externamente — solo accesible desde
  el backend en localhost.
- El modelo de datos completo se documenta en `MODELO_DATOS.md`.
- Las tablas `eventos_auditoria` y `ai_request_log` se configuran
  sin permisos de `UPDATE` ni `DELETE` — solo `INSERT` (RN-AUD-02).
- La unicidad del radicado judicial se garantiza con restricción
  `UNIQUE(radicado)` a nivel de base de datos (RN-UNI-03). La unicidad
  es simple — el radicado es único por sí solo en el sistema, no
  requiere clave compuesta con otro campo.
- Las migraciones de esquema se gestionan con el ORM elegido
  (decisión en ADR-006) — no se aplican cambios manuales en producción.
- Backup diario obligatorio a las 02:00, retención 30 días,
  copia externa requerida (ver `DESPLIEGUE_VM.md`).
