# CHECKLIST PREPRODUCCIÓN MÍNIMO — E8-04

**Proyecto:** LEX_PENAL  
**Fase:** E8  
**Fecha:** 2026-03-30  
**Estado:** EMITIDO

---

## 1. Build

| # | Verificación | Comando | Estado |
|---|--------------|---------|--------|
| 1.1 | Build compila sin errores | `npm run build` | ⬜ |
| 1.2 | Directorio `dist/` generado | `ls dist/` | ⬜ |
| 1.3 | Dependencias instaladas | `npm ci` | ⬜ |

---

## 2. Variables de entorno

| # | Variable | Verificación | Estado |
|---|----------|--------------|--------|
| 2.1 | NODE_ENV | = `production` | ⬜ |
| 2.2 | PORT | Definido (3001 o configurable) | ⬜ |
| 2.3 | DATABASE_URL | Credenciales producción | ⬜ |
| 2.4 | JWT_SECRET | Generado con `openssl rand -base64 64` | ⬜ |
| 2.5 | JWT_EXPIRES_IN | Valor adecuado (ej: 24h) | ⬜ |
| 2.6 | COOKIE_SECRET | Generado único para producción | ⬜ |
| 2.7 | COOKIE_SECURE | = `true` | ⬜ |
| 2.8 | CORS_ORIGIN | Dominio producción | ⬜ |
| 2.9 | LOG_LEVEL | = `info` o `warn` | ⬜ |
| 2.10 | ANTHROPIC_API_KEY | Clave válida verificada | ⬜ |
| 2.11 | BOOTSTRAP_ADMIN_ENABLED | = `false` (después de primer uso) | ⬜ |

---

## 3. Base de datos

| # | Verificación | Comando/Acción | Estado |
|---|--------------|----------------|--------|
| 3.1 | PostgreSQL accesible | `psql -h HOST -U USER -d DB -c '\dt'` | ⬜ |
| 3.2 | Migraciones aplicadas | `npx prisma migrate deploy` | ⬜ |
| 3.3 | Usuario admin creado | Verificar en tabla `usuario` | ⬜ |
| 3.4 | Backup pre-despliegue | `pg_dump -Fc lexpenal > backup.dump` | ⬜ |

---

## 4. Logs

| # | Verificación | Estado |
|---|--------------|--------|
| 4.1 | LOG_LEVEL configurado para producción | ⬜ |
| 4.2 | Directorio de logs definido (si aplica) | ⬜ |
| 4.3 | Rotación de logs configurada (logrotate o PM2) | ⬜ |

---

## 5. Puertos y red

| # | Verificación | Estado |
|---|--------------|--------|
| 5.1 | Puerto 3001 disponible | ⬜ |
| 5.2 | Firewall permite tráfico al puerto | ⬜ |
| 5.3 | Reverse proxy configurado (si aplica) | ⬜ |
| 5.4 | HTTPS activo (si salida pública) | ⬜ |

---

## 6. Validación del servicio

**Nota:** No existe endpoint `/health` dedicado. La validación se realiza con rutas operativas reales.

| # | Verificación | Comando | Esperado | Estado |
|---|--------------|---------|----------|--------|
| 6.1 | Servidor responde | `curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/v1` | 200 o 401 | ⬜ |
| 6.2 | Auth funciona | `POST /api/v1/auth/login` con admin | 200 + token | ⬜ |
| 6.3 | DB conectada | `GET /api/v1/cases` con token válido | 200 | ⬜ |

---

## 7. Rollback

| # | Verificación | Estado |
|---|--------------|--------|
| 7.1 | Versión anterior respaldada | ⬜ |
| 7.2 | `.env` productivo respaldado | ⬜ |
| 7.3 | Dump de DB pre-despliegue | ⬜ |
| 7.4 | Comando de rollback documentado | ⬜ |
| 7.5 | Validación post-rollback definida | ⬜ |

---

## 8. Resumen

| Sección | Items | Críticos |
|---------|-------|----------|
| Build | 3 | 2 |
| Variables | 11 | 6 (secretos + DB) |
| Base de datos | 4 | 4 |
| Logs | 3 | 1 |
| Puertos | 4 | 2 |
| Validación | 3 | 3 |
| Rollback | 5 | 3 |
| **Total** | **33** | **21** |

---

## 9. Criterio de aprobación

- Todos los items críticos marcados ✅
- Build verde
- Servidor responde
- Login funciona

**Sin estos 4 puntos, no se autoriza salida a producción.**
