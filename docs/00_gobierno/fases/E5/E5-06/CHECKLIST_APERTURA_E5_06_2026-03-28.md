# CHECKLIST APERTURA E5-06 — CIERRE ADMINISTRATIVO USERS

**Fecha:** 2026-03-28
**Unidad:** E5-06
**Tipo:** Apertura formal

---

## 1. OBJETIVO

Completar la superficie administrativa mínima del módulo `users`:
- `GET /api/v1/users` — listar usuarios
- `GET /api/v1/users/:id` — detalle de usuario
- `PUT /api/v1/users/:id` — actualizar usuario

---

## 2. ALCANCE

### Incluye
- Implementación de 3 endpoints administrativos
- Control de acceso solo administrador
- Respuesta saneada (nunca password_hash)
- Validación de email duplicado en update

### Excluye
- Cambio de contraseña
- Reset de contraseña
- DELETE usuarios
- Paginación avanzada
- Filtros complejos
- Auditoría extendida

---

## 3. ARCHIVOS A MODIFICAR

| Archivo | Acción |
|---------|--------|
| `src/modules/users/dto/update-user.dto.ts` | Reemplazar |
| `src/modules/users/users.repository.ts` | Reemplazar |
| `src/modules/users/users.service.ts` | Reemplazar |
| `src/modules/users/users.controller.ts` | Reemplazar |

---

## 4. SECUENCIA DE APLICACIÓN

```bash
# 1. Respaldar
cp src/modules/users/dto/update-user.dto.ts src/modules/users/dto/update-user.dto.ts.bak
cp src/modules/users/users.repository.ts src/modules/users/users.repository.ts.bak
cp src/modules/users/users.service.ts src/modules/users/users.service.ts.bak
cp src/modules/users/users.controller.ts src/modules/users/users.controller.ts.bak

# 2. Reemplazar con archivos descargados
# - update-user.dto.ts
# - users.repository.ts
# - users.service.ts
# - users.controller.ts

# 3. Compilar
npm run build

# 4. Reiniciar
npm run start:dev

# 5. Ejecutar pruebas
chmod +x test_e5_06.sh
./test_e5_06.sh
```

---

## 5. CRITERIOS DE CIERRE

| # | Criterio | Prueba |
|---|----------|--------|
| 1 | GET /users → 200 | 04 |
| 2 | GET /users/:id existente → 200 | 07 |
| 3 | GET /users/:id inexistente → 404 | 09 |
| 4 | PUT /users/:id actualiza nombre | 10 |
| 5 | PUT /users/:id actualiza activo | 11 |
| 6 | PUT /users/:id actualiza email | 12 |
| 7 | PUT /users/:id email duplicado → 409 | 14 |
| 8 | usuario no admin → 403 | 15, 16, 17 |
| 9 | password_hash nunca expuesto | 03, 05, 08, 13 |
| 10 | npm run build verde | Manual |

**Condición de cierre:** 17 PASS, 0 FAIL + build verde

---

## 6. REGLAS DE DISEÑO

### Acceso
- JwtAuthGuard en todos los endpoints
- assertAdmin() centralizado en controller

### Respuesta saneada
```typescript
{
  id: string;
  nombre: string;
  email: string;
  perfil: string;
  activo: boolean;
  creado_en: Date;
}
```

### Update controlado
Campos permitidos: `nombre`, `email`, `perfil`, `activo`

### Email duplicado
- `emailExistsExcluding(email, excludeUserId)` valida duplicado
- Si email pertenece al mismo usuario → permitido
- Si pertenece a otro → 409

### Enum
- DTO/controller: `PerfilUsuario` de dominio
- service: `toPrismaPerfil()` traduce a Prisma
- repository: recibe ya traducido

---

## 7. NOTAS

- No se modifica `GET /me` (ya operativo)
- No se modifica `POST /users` (ya operativo)
- `QueryUsersDto` no se usa en esta versión (sin filtros)
