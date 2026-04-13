# NOTA DE CIERRE — E9-01.A — Reactivación y verificación técnica de lexum-main
**Proyecto:** LEX_PENAL  
**Fase:** E9  
**Unidad asociada:** E9-01  
**Subbloque:** E9-01.A — Reactivación y verificación técnica de `lexum-main`  
**Fecha de cierre:** 2026-04-12  
**Estado:** CERRADO

## 1. Objeto del subbloque
Reactivar y verificar técnicamente el host `lexum-main` como entorno staging formal del proyecto, validando acceso, estado general, recursos, red, servicios base y capacidad real para alojar el backend.

## 2. Resultado general
Se concluye que **`lexum-main` es APTO PARA STAGING CON OBSERVACIONES MENORES**.

## 3. Evidencia técnica consolidada

### 3.1 Host e infraestructura
- Host activo y estable.
- Sistema operativo: Ubuntu 24.04.4 LTS.
- Uptime aproximado al momento de la verificación: 3 días.
- Sin unidades fallidas en `systemctl`.
- Recursos suficientes para staging:
  - CPU lógicas: 6
  - Memoria total: ~11 GiB
  - Memoria disponible: ~10 GiB
  - Disco raíz libre: ~41 GiB

### 3.2 Red y exposición
- IP pública operativa: `207.180.248.126`
- IP Tailscale operativa: `100.107.143.15`
- SSH endurecido:
  - `Port 2222`
  - `PermitRootLogin no`
  - `PubkeyAuthentication yes`
  - `PasswordAuthentication no`

### 3.3 Firewall
- `80/tcp` y `443/tcp` permitidos.
- `22/tcp` bloqueado públicamente.
- `2222/tcp` bloqueado públicamente.
- `2222/tcp` permitido solo por `tailscale0`.

### 3.4 Servicios base
- `nginx` activo y habilitado.
- `postgresql` activo y habilitado.
- `tailscaled`, `fail2ban`, `ufw`, `docker`, `wazuh-agent` presentes.
- PostgreSQL escuchando solo en loopback (`127.0.0.1:5432`, `::1:5432`).

### 3.5 Backend desplegado
- Ruta operativa detectada: `/opt/lex_penal/app`
- `.env` enlazado a `/opt/lex_penal/shared/.env`
- Artefactos `dist/` presentes.
- Usuario runtime `lexpenal` con lectura válida de `.env` y `dist/main.js`.

## 4. Verificación de arranque controlado del backend
Se creó y habilitó correctamente la unidad:

- `lex-penal.service`

Resultado de arranque:
- Servicio `active/running` por `systemd`
- Proceso `node dist/main.js` ejecutándose como `lexpenal`
- Puerto de escucha confirmado: `3010`
- Journal de NestJS mostrando arranque correcto
- Mensaje de arranque:
  - `Nest application successfully started`
  - `LexPenal backend running on port 3010`

Smoke test local:
- `curl http://127.0.0.1:3010/` respondió `404 Not Found`

Interpretación:
- La respuesta `404` en `/` **no constituye fallo**
- Acredita que el backend está vivo y respondiendo HTTP, aunque no expone ruta raíz

## 5. Observaciones
1. El repo del host quedó en **detached HEAD** sobre commit `32f838f`.
2. El servicio `lex-penal` ya existe y queda instalado como base operativa de staging.
3. Existen puertos locales heredados:
   - `127.0.0.1:4443` por `nginx`
   - `127.0.0.1:8080` por `docker-proxy`
   Estos no bloquean el backend en `3010`.
4. Los secretos de aplicación fueron impresos durante la sesión de trabajo/registro operativo, por lo cual deben considerarse **materialmente expuestos** y deberán rotarse antes de una exposición más amplia del entorno.

## 6. Decisión de cierre
Se declara **CERRADO** el subbloque **E9-01.A** por cumplimiento material de su propósito.

## 7. Salida del subbloque
Queda habilitada la apertura del siguiente bloque:

**E9-02 — Exposición controlada del backend en staging mediante nginx**

## 8. Pendientes heredados a E9-02
- Identificar el vhost objetivo de staging
- Definir ruta o subdominio de exposición
- Configurar reverse proxy hacia `127.0.0.1:3010`
- Validar acceso HTTP/HTTPS controlado al backend
- Evaluar rotación de secretos expuestos en sesión
- Documentar estado de detached HEAD y plan de sincronización documental al repo principal
