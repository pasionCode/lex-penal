# Manual operativo — LexPenal MVP

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha | 2026-03-06 |
| Estado | Vigente |
| Entorno | Producción — VM única Ubuntu 24.04 LTS |

---

## 1. Propósito

Este manual describe cómo se opera el sistema LexPenal en producción:
cómo se gestionan los casos, cómo se administran usuarios, cómo se
mantiene la infraestructura y cómo se responde ante incidentes.

No repite la arquitectura ni el diseño del sistema. Los documentos
de referencia técnica están en las secciones indicadas al final.

**Alcance**: operación del MVP en VM de producción. No cubre
entornos de desarrollo ni staging.

**A quién va dirigido**:
- Supervisores y estudiantes del consultorio — secciones 3 y 4.
- Administradores del sistema — sección 5.
- Operador técnico responsable del servidor — secciones 6, 7, 8 y 9.

---

## 2. Perfiles operativos

| Perfil | Quién es | Qué puede hacer en el sistema |
|---|---|---|
| `estudiante` | Estudiante asignado al caso | Crear y diligenciar casos, usar el asistente de IA, solicitar revisión, ver retroalimentación, generar los informes que su perfil y el estado del caso permitan |
| `supervisor` | Docente o supervisor del consultorio | Revisar casos en `pendiente_revision`, registrar observaciones formales, aprobar o devolver, consultar historial de revisiones |
| `administrador` | Coordinador o responsable técnico del consultorio | Alta y baja de usuarios, asignación de perfiles, consulta global, reasignación excepcional de casos |
| Operador técnico | Responsable del servidor | Mantenimiento de VM, reinicio de servicios, revisión de logs, backups, certificados TLS |

El administrador del sistema y el operador técnico pueden ser la
misma persona en contextos de consultorio pequeño.

---

## 3. Operación funcional — flujo del caso

### 3.1 Crear un caso

El estudiante inicia sesión y accede al botón **Nuevo caso** en el
dashboard. Completa los datos de la ficha básica: datos del procesado,
radicado, delito imputado y juzgado. El caso queda en estado `borrador`
hasta que el estudiante lo active.

Para activar el análisis: el estudiante selecciona **Iniciar análisis**.
El caso pasa a `en_analisis` y todas las herramientas quedan disponibles
para edición.

### 3.2 Diligenciar herramientas

En estado `en_analisis` el estudiante tiene acceso a las ocho
herramientas del expediente: Ficha, Hechos, Pruebas, Riesgos,
Estrategia, Explicación al cliente, Checklist y Conclusión.

El asistente de IA está disponible en cada herramienta. El estudiante
puede consultarlo sin restricción — las respuestas son orientativas
y no se escriben automáticamente en el expediente.

El progreso del checklist es visible en todo momento en el panel
del caso. Los bloques críticos incompletos impiden el envío a revisión.

### 3.3 Enviar a revisión

Cuando el estudiante considera que el análisis está completo, selecciona
**Enviar a revisión**. El sistema verifica:

1. Que no haya bloques críticos incompletos en el checklist.
2. Que los mínimos obligatorios de las herramientas estén cumplidos.

Si alguna verificación falla, el sistema informa los bloques o campos
pendientes con código `422`. El caso no avanza hasta resolver los
incumplimientos. Si todo está correcto, el caso pasa a `pendiente_revision`.

### 3.4 Revisar el caso (supervisor)

El supervisor ve todos los casos en `pendiente_revision` en su
dashboard. Accede al caso y puede consultar cada herramienta en
modo lectura. Registra observaciones por herramienta o globales
y decide:

- **Aprobar**: el caso pasa a `aprobado_supervisor`. El estudiante
  puede generar el informe de conclusión operativa y continuar al
  cierre con el cliente.
- **Devolver**: el caso pasa a `devuelto`. El responsable consulta
  las observaciones del supervisor, retoma el caso en `en_analisis`,
  corrige las herramientas señaladas y lo reenvía a revisión.

Las observaciones son obligatorias en cualquier decisión — el sistema
no permite aprobar ni devolver sin texto de retroalimentación.

### 3.5 Corregir y reenviar

El responsable del caso accede al expediente en estado `devuelto`,
consulta las observaciones del supervisor y retoma el análisis
en `en_analisis`. Puede corregir todas las herramientas del caso
y volver a enviar a revisión tantas veces como sea necesario.
El historial de revisiones anteriores queda visible pero no puede
modificarse.

### 3.6 Generar informes

Los informes están disponibles según el estado del caso y el perfil
del usuario. El botón de generación indica el tipo de informe y
el formato (PDF o DOCX). El sistema verifica las precondiciones antes
de generar — si no se cumplen, informa el motivo.

El informe de conclusión operativa requiere:
- Estado `aprobado_supervisor`.
- Checklist sin bloques críticos incompletos.

Cada informe generado queda registrado con fecha, usuario y estado
del caso en el momento de la generación.

### 3.7 Cerrar el caso

Una vez entregado al cliente, el administrador o el supervisor puede
marcar el caso como `cerrado`. El caso en `cerrado` es de solo
lectura para todos los perfiles. No existe reapertura de casos
cerrados en el MVP.

---

## 4. Operación del supervisor

### Acceso al panel de revisión

El supervisor accede al sistema con sus credenciales. Su dashboard
principal prioriza los casos en `pendiente_revision`, sin perjuicio
de las vistas históricas o de consulta que el sistema habilite
según su perfil.

### Registro de retroalimentación

Por cada revisión el supervisor debe:
1. Revisar cada herramienta del expediente.
2. Registrar observaciones específicas — globales o por herramienta.
3. Indicar su decisión: aprobar o devolver.

El sistema no valida la calidad del razonamiento jurídico — esa
evaluación es responsabilidad exclusiva del supervisor.

### Historial formal de revisiones

Cada revisión queda registrada con versión, fecha, resultado y texto
de observaciones. El historial no puede modificarse. El supervisor
puede consultar revisiones anteriores del mismo caso para seguimiento
del progreso del estudiante.

---

## 5. Operación administrativa

### Alta de usuarios

El administrador accede al panel de administración y selecciona
**Nuevo usuario**. Registra nombre, correo institucional y perfil
inicial. El administrador habilita el acceso del nuevo usuario
según el mecanismo de activación definido por el sistema.

Un usuario inactivo (`activo = false`) no puede iniciar sesión. Para
suspender temporalmente el acceso sin eliminar el usuario, el
administrador desactiva la cuenta.

### Asignación y cambio de perfiles

Solo el administrador puede modificar el perfil de un usuario. El
cambio aplica en la siguiente sesión del usuario afectado. Un estudiante
promovido a supervisor no accede a funciones de supervisor hasta que
la sesión actual expire o cierre sesión.

### Consulta global

El administrador puede ver todos los casos del sistema independientemente
de su estado o del estudiante asignado. No puede editar el análisis
de los casos — solo consultar y ejecutar acciones administrativas
excepcionales como la reasignación.

### Control de incidencias funcionales

Cuando un usuario reporta un error funcional (el sistema no permite
una acción que debería estar habilitada, o permite una que no debería),
el administrador debe:
1. Registrar el caso con usuario, acción y mensaje de error.
2. Verificar el estado del caso y el perfil del usuario en el panel.
3. Si el error persiste sin explicación funcional, escalar al
   operador técnico con el detalle del error y el identificador del caso.

---

## 6. Operación técnica básica

Los comandos de esta sección se ejecutan en el servidor de producción
con el usuario operativo no root. Solo en casos excepcionales se
usa `sudo`.

### 6.1 Estado general del sistema

```bash
# Estado de los servicios gestionados por PM2
pm2 status

# Logs en tiempo real (frontend y backend)
pm2 logs

# Estado de Nginx
sudo systemctl status nginx

# Estado de PostgreSQL
sudo systemctl status postgresql
```

### 6.2 Reiniciar servicios

```bash
# Reiniciar solo el backend
pm2 restart lexpenal-backend

# Reiniciar solo el frontend
pm2 restart lexpenal-frontend

# Reiniciar ambos
pm2 restart all

# Recargar Nginx sin cortar conexiones activas
sudo nginx -t && sudo systemctl reload nginx
```

Antes de reiniciar Nginx siempre ejecutar `nginx -t` para verificar
que la configuración es válida. Un reinicio con configuración
inválida deja el servidor inaccesible.

### 6.3 Logs de aplicación

```bash
# Logs de backend (últimas 100 líneas)
pm2 logs lexpenal-backend --lines 100

# Logs de Nginx (errores)
sudo tail -n 100 /var/log/nginx/error.log

# Logs de PostgreSQL
sudo tail -n 100 /var/log/postgresql/postgresql-*.log
```

Los logs de aplicación no deben contener secretos, tokens completos
ni contraseñas. Si se detecta un secreto en logs, rotar la credencial
afectada inmediatamente.

### 6.4 Salud del sistema

```bash
# Uso de disco
df -h

# Uso de memoria
free -h

# Procesos activos por consumo de CPU
top -b -n 1 | head -20
```

Si el disco supera el 80% de uso, revisar logs antiguos y backups
que no hayan sido rotados. El crecimiento inesperado de `ai_request_log`
puede ser una causa frecuente.

### 6.5 Certificado TLS

```bash
# Verificar fecha de expiración del certificado
sudo certbot certificates

# Forzar renovación manual si certbot no renovó automáticamente
sudo certbot renew --force-renewal
sudo systemctl reload nginx
```

Certbot renueva automáticamente. Verificar mensualmente que la
renovación automática está activa. Un certificado vencido bloquea
el acceso de todos los usuarios.

---

## 7. Backups y restauración

### 7.1 Backup automático

El backup de la base de datos se ejecuta diariamente a las 02:00
mediante un script programado en `cron`. Los archivos se almacenan
fuera del servidor de producción con retención de 30 días.
Los archivos de backup deben almacenarse con permisos restringidos
y fuera de rutas públicas — un backup expuesto equivale a datos
expuestos.

```bash
# Verificar que el cron de backup está activo
crontab -l

# Ejecutar backup manual
pg_dump -U lexpenal_user lexpenal_db > /ruta/backup/lexpenal_$(date +%Y%m%d).sql
```

### 7.2 Prueba de restauración

La restauración debe probarse periódicamente — al menos una vez
al mes. Un backup no verificado no es un backup.

```bash
# Restaurar sobre base de datos de prueba (nunca sobre producción directamente)
psql -U lexpenal_user lexpenal_db_test < /ruta/backup/lexpenal_20260306.sql
```

El procedimiento de restauración en producción ante una pérdida real:
1. Detener backend: `pm2 stop lexpenal-backend`.
2. Restaurar el backup más reciente sobre la base de producción.
3. Verificar integridad básica: contar registros en tablas críticas.
4. Reiniciar backend: `pm2 start lexpenal-backend`.
5. Verificar acceso funcional antes de notificar a usuarios.

### 7.3 Contingencia mínima

Si la base de datos no puede restaurarse y el backup falla:
1. No reiniciar el servidor — los datos en memoria pueden ser
   recuperables.
2. Contactar al responsable técnico del proyecto.
3. No intentar reparación manual de PostgreSQL sin experiencia
   específica en recuperación de datos.

---

## 8. Gestión de incidentes

### 8.1 El backend no responde

**Síntomas**: el frontend muestra errores de conexión o `502 Bad Gateway`.

```bash
pm2 status                        # verificar si el proceso está activo
pm2 logs lexpenal-backend --lines 50   # revisar último error
pm2 restart lexpenal-backend      # reiniciar si el proceso está caído
```

Si el proceso reinicia pero vuelve a caer en segundos, revisar los
logs para identificar el error de inicio (configuración inválida,
variable de entorno faltante, puerto ocupado).

### 8.2 El frontend no responde

**Síntomas**: la URL del sistema no carga o muestra página en blanco.

```bash
pm2 status
pm2 logs lexpenal-frontend --lines 50
pm2 restart lexpenal-frontend
sudo systemctl status nginx
```

Si Nginx está activo pero el frontend no responde, verificar que
el puerto del frontend (3000) está en escucha:
```bash
ss -tlnp | grep 3000
```

### 8.3 El módulo de IA no responde

**Síntomas**: el asistente de IA muestra error o no retorna respuesta.

El módulo de IA falla de forma aislada — no afecta el flujo del caso.
Los usuarios pueden continuar trabajando sin IA.

Verificar:
1. Que las variables de entorno del proveedor de IA están configuradas.
2. Que el proveedor externo no tiene incidentes reportados.
3. Los logs del backend para el mensaje de error específico del adaptador.

No es un incidente crítico. Registrar y monitorear. Si el fallo
persiste más de 24 horas, notificar al equipo técnico.

### 8.4 La generación de informes falla

**Síntomas**: el botón de generación retorna error o el archivo descargado está vacío.

Verificar:
1. El estado del caso y las precondiciones del informe (checklist,
   estado, perfil) — puede ser un error funcional, no técnico.
2. Los logs del backend para el error específico del generador.
3. El espacio en disco disponible en el servidor.

Si el error es técnico y persiste, el estudiante puede continuar
El fallo técnico en la generación del informe no bloquea el análisis
del caso, pero puede impedir temporalmente su entrega formal hasta
que se restablezca el servicio.

### 8.5 La base de datos no responde

**Síntomas**: errores de conexión en el backend, logs con
`connection refused` a PostgreSQL.

```bash
sudo systemctl status postgresql
sudo systemctl start postgresql    # si el servicio está detenido
sudo journalctl -u postgresql -n 50   # logs de PostgreSQL
```

Si PostgreSQL no arranca, revisar espacio en disco — PostgreSQL
puede detenerse si el disco está lleno. No intentar reparar
archivos de datos manualmente. Contactar al responsable técnico.

### 8.6 El certificado TLS vence o ya venció

**Síntomas**: los usuarios reciben advertencia de sitio no seguro.
El sistema sigue funcionando pero los navegadores bloquean el acceso.

```bash
sudo certbot renew --force-renewal
sudo systemctl reload nginx
```

Si la renovación falla, verificar que el puerto 80 está abierto
(Certbot necesita responder al challenge HTTP) y que el dominio
resuelve correctamente al IP del servidor.

---

## 9. Tareas operativas periódicas

### Diarias

- Verificar que PM2 reporta todos los procesos como `online`.
- Verificar que el backup de la noche anterior se ejecutó correctamente.
- Revisar logs de error de Nginx y backend en busca de errores
  recurrentes o inesperados.

### Semanales

- Revisar uso de disco — confirmar que está por debajo del 80%.
- Revisar logs de `ai_request_log` — crecimiento inusual puede
  indicar uso excesivo o errores silenciosos.
- Verificar que no hay actualizaciones críticas de seguridad
  pendientes en el sistema operativo.

```bash
sudo apt update && apt list --upgradable 2>/dev/null | grep -i security
```

### Mensuales

- Probar la restauración de backup en entorno de prueba.
- Verificar la fecha de expiración del certificado TLS.
- Revisar usuarios activos — desactivar cuentas de estudiantes
  que ya no están en el consultorio.
- Revisar que las variables de entorno de producción siguen siendo
  las correctas (sin credenciales vencidas o rotadas sin actualizar).

---

## 10. Límites operativos del MVP

El sistema no resuelve en el MVP:

| Situación | Manejo actual |
|---|---|
| Reapertura de caso cerrado | No disponible — requiere intervención técnica excepcional si es indispensable |
| Notificaciones automáticas | No hay — el supervisor revisa su dashboard manualmente |
| Múltiples consultorios configurados | No disponible — instalación única por consultorio |
| Autenticación de dos factores | No disponible — planeado para Fase 2 |
| Recuperación de contraseña self-service | No disponible — el administrador restablece la contraseña manualmente |
| Eliminación de casos | No disponible — el ciclo termina en `cerrado` |
| Alta disponibilidad | No disponible — punto único de falla aceptado formalmente en ADR-001 |

Cualquier situación no cubierta por el sistema en su estado actual
requiere intervención del administrador o del operador técnico,
con registro manual del hecho.

---

## 11. Referencias cruzadas

| Documento | Dónde |
|---|---|
| Despliegue de la VM | `docs/07_infraestructura/DESPLIEGUE_VM.md` |
| Seguridad base | `docs/08_seguridad/SEGURIDAD_BASE.md` |
| Calidad base y criterios de aceptación | `docs/09_calidad/CALIDAD_BASE.md` |
| Roles y permisos | `docs/01_producto/MATRIZ_ROLES_PERMISOS.md` |
| Estados del caso y transiciones | `docs/01_producto/ESTADOS_DEL_CASO.md` |
| Catálogo de informes y precondiciones | `docs/01_producto/CATALOGO_INFORMES.md` |
| Arquitectura del backend | `docs/06_backend/ARQUITECTURA_BACKEND.md` |
| ADR-001 — despliegue en VM única | `docs/00_gobierno/adrs/ADR-001-despliegue-inicial-vm.md` |
| ADR-004 — módulo IA desacoplado | `docs/00_gobierno/adrs/ADR-004-modulo-ia-desacoplado.md` |
