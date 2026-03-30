# ESTRATEGIA DE DESPLIEGUE OBJETIVO — E8-03

**Proyecto:** LEX_PENAL  
**Fase:** E8  
**Fecha:** 2026-03-30  
**Estado:** DEFINIDA

---

## 1. Destino objetivo

| Campo | Valor |
|-------|-------|
| Destino | Pendiente de definición (candidato: lexum-main o VPS dedicado) |
| Base de datos | PostgreSQL — instancia de producción por definir |
| Dominio/subdominio | Pendiente |
| HTTPS | Requerido para salida pública |

---

## 2. Modalidad de despliegue elegida

**Opción seleccionada:** Node/NestJS directo con PM2 detrás de reverse proxy.

| Criterio | Justificación |
|----------|---------------|
| Complejidad | Mínima — sin contenedorización obligatoria |
| Tiempo de salida | Corto — no requiere pipeline CI/CD |
| Suficiencia | Adecuada para MVP y siguiente bloque operativo |
| Escalabilidad posterior | PM2 permite clustering si se requiere |

**Lo que no entra en esta fase:**
- CI/CD completo
- Contenedorización obligatoria
- Observabilidad avanzada
- Autoescalado
- Pipeline de release

---

## 3. Prerrequisitos

| # | Prerrequisito | Estado |
|---|---------------|--------|
| 1 | Servidor Linux objetivo disponible | ⏳ Pendiente |
| 2 | Node LTS instalado (>=18) | ⏳ Pendiente |
| 3 | PostgreSQL accesible | ⏳ Pendiente |
| 4 | Variables de entorno de producción listas | ⚠️ Requiere saneamiento |
| 5 | Usuario de sistema para la app | ⏳ Pendiente |
| 6 | Puerto operativo definido (3001 o configurable) | ✅ Definido |
| 7 | Política básica de logs | ⏳ Pendiente |
| 8 | PM2 instalado para restart automático | ⏳ Pendiente |
| 9 | Respaldo de base de datos previo a salida | ⏳ Pendiente |

---

## 4. Dependencias operativas

| Dependencia | Responsable | Estado |
|-------------|-------------|--------|
| Acceso al servidor destino | Infraestructura | ⏳ |
| Credenciales PostgreSQL producción | DBA / Infraestructura | ⏳ |
| JWT_SECRET definitivo | Desarrollo | ⚠️ Generar |
| COOKIE_SECRET definitivo | Desarrollo | ⚠️ Generar |
| Dominio/subdominio | Infraestructura | ⏳ |
| Certificado HTTPS | Infraestructura | ⏳ |
| Política CORS producción | Desarrollo | ⚠️ Configurar |
| Clave Anthropic válida | Desarrollo | ⏳ Verificar |

---

## 5. Rollback básico

| Paso | Acción |
|------|--------|
| 1 | Conservar versión estable anterior del build en directorio separado |
| 2 | Respaldar `.env` productivo antes de cualquier cambio |
| 3 | Snapshot o dump de base de datos antes de despliegue |
| 4 | Si falla: `pm2 stop` nueva versión, restaurar directorio anterior, `pm2 start` |
| 5 | Validación post-rollback: verificar respuesta del servidor + login básico |

**Comando de rollback típico:**
```bash
pm2 stop lexpenal
mv /app/lexpenal /app/lexpenal-failed
mv /app/lexpenal-backup /app/lexpenal
pm2 start lexpenal
curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/v1
```

**Nota:** No existe endpoint `/health` dedicado. La validación se realiza verificando respuesta HTTP del servidor y login funcional.

---

## 6. Criterio de salida

**Decisión: Apto con observaciones**

Sujeto a:
- [ ] Saneamiento de secretos (JWT_SECRET, COOKIE_SECRET)
- [ ] Credenciales productivas de PostgreSQL
- [ ] Definición de destino final (servidor)
- [ ] Checklist preproducción emitido
- [ ] Dominio/HTTPS si salida pública

---

## 7. Resumen de estrategia

Se define como estrategia objetivo de despliegue una salida operativa incremental, priorizando un despliegue simple y controlado del backend NestJS mediante proceso administrado (PM2), configuración externalizada por variables de entorno y conexión a base de datos PostgreSQL de producción.

La estrategia evita, en esta fase, incorporar complejidad adicional como CI/CD completo o contenedorización obligatoria, reservando esos componentes para un bloque posterior si la decisión operativa lo exige.

La salida queda condicionada al saneamiento de secretos, preparación del entorno destino y emisión del checklist preproducción.
