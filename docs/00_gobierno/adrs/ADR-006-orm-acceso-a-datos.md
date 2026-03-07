# ADR-006 — ORM y acceso a datos

| Campo | Valor |
|---|---|
| Estado | Propuesta — **requiere decisión antes de iniciar desarrollo** |
| Fecha | (completar al decidir) |
| Decisor | (completar) |
| Documentos relacionados | `docs/06_backend/ARQUITECTURA_BACKEND.md`, `docs/09_despliegue/DESPLIEGUE_VM.md` |

---

## Contexto

LexPenal requiere un mecanismo para acceder a PostgreSQL desde NestJS,
ejecutar migraciones de esquema de manera controlada y mantener los
repositorios como única vía de escritura a base de datos.

Esta decisión es el **bloqueador técnico número uno** del proyecto.
No puede escribirse ningún repositorio, ninguna migración ni ningún
módulo de acceso a datos sin que esté cerrada. Afecta directamente:

- la estructura de los repositorios (`infrastructure/repositories/`);
- el comando de migración en el pipeline de despliegue;
- la forma en que se definen entidades y relaciones;
- el contrato entre `CasoEstadoService` y la capa de persistencia.

Las dos opciones viables dentro del stack NestJS + PostgreSQL son
**TypeORM** y **Prisma**. Ambas son maduras, tienen integración oficial
con NestJS y soportan migraciones.

---

## Opciones evaluadas

### Opción A — TypeORM

TypeORM es el ORM más integrado en el ecosistema NestJS. Las entidades
se definen como clases decoradas con TypeScript, y el módulo `@nestjs/typeorm`
ofrece integración directa con el sistema de inyección de dependencias.

**Ventajas**
- Integración nativa con NestJS — patrón `Repository<T>` inyectable directamente.
- Las entidades son clases TypeScript con decoradores — misma tecnología que el resto del backend.
- Motor de migraciones incorporado (`TypeORM migrations`).
- Amplia documentación y comunidad dentro del ecosistema NestJS.
- El patrón Active Record o Data Mapper es configurable — LexPenal usaría Data Mapper para mantener separación limpia.

**Desventajas**
- El tipo inferido de las entidades no siempre es preciso — puede requerir tipado manual en casos complejos.
- Las migraciones generadas automáticamente pueden diferir del esquema esperado si los decoradores no están bien configurados — requieren revisión manual.
- El mantenimiento de TypeORM ha sido menos activo en los últimos años comparado con Prisma.

**Comando de migración en despliegue**
```bash
npm run migration:run
```

**Estructura de entidad ejemplo**
```typescript
@Entity('casos')
export class CasoEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  radicado: string;

  @Column({ type: 'enum', enum: EstadoCaso })
  estado_actual: EstadoCaso;
}
```

---

### Opción B — Prisma

Prisma tiene un enfoque diferente: el esquema se define en un archivo
`.prisma` con su propio lenguaje declarativo, y Prisma genera un cliente
TypeScript fuertemente tipado a partir de ese esquema.

**Ventajas**
- El cliente generado es **fuertemente tipado de manera exacta** — si el esquema cambia, el código que no lo sigue deja de compilar.
- El archivo `schema.prisma` es la fuente de verdad única y legible del modelo de datos — fácil de auditar.
- `Prisma Migrate` genera migraciones SQL limpias y predecibles.
- Experiencia de desarrollo más rápida para consultas complejas gracias al autocompletado preciso.

**Desventajas**
- La integración con NestJS requiere un `PrismaService` manual como capa adaptadora — no hay inyección directa equivalente a `Repository<T>`.
- El archivo `schema.prisma` es un lenguaje propio — curva de aprendizaje adicional para el equipo.
- El cliente Prisma es un proceso separado que debe generarse (`prisma generate`) antes de compilar — añade un paso al pipeline.

**Comando de migración en despliegue**
```bash
npx prisma migrate deploy
```

**Estructura de esquema ejemplo**
```prisma
model Caso {
  id           String     @id @default(uuid())
  radicado     String
  estado_actual EstadoCaso
  @@map("casos")
}
```

---

## Criterios de decisión

| Criterio | Peso | TypeORM | Prisma |
|---|---|---|---|
| Integración con NestJS | Alto | Nativa | Manual (PrismaService) |
| Tipado preciso | Alto | Parcial | Exacto |
| Migraciones predecibles | Alto | Requieren revisión | Limpias por defecto |
| Familiaridad del equipo | Alto | (evaluar) | (evaluar) |
| Mantenimiento del proyecto | Medio | Menor actividad reciente | Activo |
| Curva de aprendizaje | Medio | Baja en NestJS | Media (schema propio) |

El criterio de **familiaridad del equipo** es determinante si el tiempo
de desarrollo es un factor crítico. Ambas opciones son técnicamente
adecuadas para LexPenal.

---

## Decisión

> **[ ] TypeORM**
> **[ ] Prisma**
>
> *(marcar la opción elegida al cerrar este ADR)*

**Justificación**: (completar al decidir)

**Decisor**: (completar)

**Fecha**: (completar)

---

## Consecuencias

### Si se elige TypeORM
- Los repositorios en `infrastructure/repositories/` extienden `Repository<EntidadEntity>`.
- Las entidades viven en `domain/entities/` como clases decoradas.
- El comando de migración en `DESPLIEGUE_VM.md` queda como `npm run migration:run`.
- Añadir `@nestjs/typeorm` y `typeorm` como dependencias.

### Si se elige Prisma
- Los repositorios inyectan `PrismaService` en lugar de `Repository<T>`.
- El esquema de datos vive en `prisma/schema.prisma` como fuente de verdad única.
- El pipeline de despliegue requiere `prisma generate` antes de `npm run build`.
- El comando de migración en `DESPLIEGUE_VM.md` queda como `npx prisma migrate deploy`.
- Añadir `prisma` y `@prisma/client` como dependencias.

### En ambos casos
- `DESPLIEGUE_VM.md` debe actualizarse con el comando de migración correcto.
- `ARQUITECTURA_BACKEND.md` debe actualizarse con la opción elegida en la tabla de stack.
- Ningún repositorio, entidad ni migración debe escribirse antes de cerrar este ADR.
