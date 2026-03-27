# BASELINE `proceedings` — Sprint 14

**Fecha:** 2026-03-26/27  
**Proyecto:** LEX_PENAL  
**Fase:** E5 — Expansión funcional controlada  
**Sprint:** 14  
**Foco:** Hardening de `proceedings`  
**Política:** A1 — Validaciones de payload

---

## 1. Contexto

Sprint 14 consolidó el módulo `proceedings` después del ajuste de política append-only realizado en Sprint 13. El objetivo fue endurecer las validaciones del DTO de creación.

---

## 2. Estado pre-ajuste

### DTO inicial

```typescript
@IsString({ message: 'descripcion debe ser texto' })
@MaxLength(1000, { message: 'descripcion no puede exceder 1000 caracteres' })
descripcion!: string;
```

### Brechas identificadas

| Prueba | Código | Resultado |
|--------|--------|-----------|
| `descripcion: ""` | 201 | ⚠️ Aceptó string vacío |
| `descripcion: "   "` | 201 | ⚠️ Aceptó solo espacios |
| `{}` payload vacío | 400 | ✅ Rechazó |
| `completada: "yes"` | 400 | ✅ Rechazó |
| `fecha: "not-a-date"` | 400 | ✅ Rechazó |

---

## 3. Intervención aplicada

### DTO final

```typescript
import { Transform } from 'class-transformer';
import {
  IsString,
  IsOptional,
  IsUUID,
  IsBoolean,
  IsDateString,
  MaxLength,
  IsNotEmpty,
} from 'class-validator';

export class CreateProceedingDto {
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @IsNotEmpty({ message: 'descripcion es requerido' })
  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(1000, { message: 'descripcion no puede exceder 1000 caracteres' })
  descripcion!: string;

  @IsOptional()
  @IsDateString({}, { message: 'fecha debe ser fecha ISO válida' })
  fecha?: string;

  @IsOptional()
  @IsUUID('4', { message: 'responsable_id debe ser UUID válido' })
  responsable_id?: string;

  @IsOptional()
  @IsString({ message: 'responsable_externo debe ser texto' })
  @MaxLength(120, { message: 'responsable_externo no puede exceder 120 caracteres' })
  responsable_externo?: string;

  @IsOptional()
  @IsBoolean({ message: 'completada debe ser booleano' })
  completada?: boolean;
}
```

### Cambios aplicados

1. Agregado `@IsNotEmpty()` para rechazar strings vacíos
2. Agregado `@Transform()` para hacer trim antes de validar
3. Removido import no usado (`ValidateIf`)
4. Agregado import de `Transform` desde `class-transformer`

---

## 4. Validación post-ajuste

### A1 — Validaciones de payload

| Prueba | Código | Mensaje | Estado |
|--------|--------|---------|--------|
| `descripcion: ""` | 400 | "descripcion es requerido" | ✅ CERRADA |
| `descripcion: "   "` | 400 | "descripcion es requerido" | ✅ CERRADA |
| POST válido completo | 201 | — | ✅ OK |
| GET lista | 200 | — | ✅ OK |
| `fecha: "not-a-date"` | 400 | "fecha debe ser fecha ISO válida" | ✅ OK |
| `completada: "yes"` | 400 | "completada debe ser booleano" | ✅ OK |

### A2 — Reglas de responsable (exploración)

| Prueba | Código | Resultado | Según contrato |
|--------|--------|-----------|----------------|
| Solo `responsable_id` | 201 | Aceptó | ✅ Válido |
| Solo `responsable_externo` | 201 | Aceptó | ✅ Válido |
| Ambos a la vez | 201 | Aceptó | ✅ No prohibido |
| Ninguno | 201 | Aceptó | ✅ Sin responsable |

**Conclusión A2:** Comportamiento compatible con el contrato actual. No hay brecha que corregir.

---

## 5. Mini-regresión

| Prueba | Código | Estado |
|--------|--------|--------|
| GET lista | 200 | ✅ |
| POST válido | 201 | ✅ |
| GET detalle | 200 | ✅ |
| PUT no expuesto | 404 Cannot PUT | ✅ |
| DELETE no expuesto | 404 Cannot DELETE | ✅ |

**Build:** Verde  
**Regresión S13:** Verde

---

## 6. Deuda técnica

### Resuelta

- Import no usado (`ValidateIf`) removido implícitamente al reescribir el DTO

### Pendiente (decisión funcional)

- ¿`responsable_id` y `responsable_externo` pueden coexistir o debe imponerse exclusión mutua (XOR)?
- Clasificación: decisión de negocio, no defecto técnico

### Cosmética (fuera de alcance)

- Mensajes ruidosos cuando campo requerido está ausente (requiere `stopAtFirstError` en main.ts)

---

## 7. Artefactos del sprint

| Archivo | Cambio |
|---------|--------|
| `src/modules/proceedings/dto/create-proceeding.dto.ts` | Hardening de validaciones |

---

*Documento generado: 2026-03-27*  
*Sprint 14 — Hardening de `proceedings`*
