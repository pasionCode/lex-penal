# Despliegue en VM

Documento de referencia para la puesta en marcha de LexPenal en una
máquina virtual de producción. Define la infraestructura requerida,
el proceso de instalación, la configuración de variables de entorno,
el arranque de servicios y las verificaciones mínimas antes de abrir
el sistema a usuarios.

**Documentos relacionados**
- `docs/06_backend/ARQUITECTURA_BACKEND.md`
- `docs/07_frontend/ARQUITECTURA_FRONTEND.md`
- `docs/08_ia/ARQUITECTURA_MODULO_IA.md`
- `docs/00_gobierno/adrs/ADR-002-base-de-datos-postgresql.md`
- `docs/00_gobierno/adrs/ADR-006-orm-acceso-a-datos.md` *(pendiente)*

| Campo | Valor |
|---|---|
| Última revisión | (completar) |
| Responsable | (completar) |

---

## Alcance

Este documento cubre el despliegue del MVP de LexPenal en una sola VM
con todos los componentes instalados en el mismo servidor.

Queda fuera de este alcance:
- Arquitectura distribuida o multi-servidor.
- Contenedores (Docker / Kubernetes) — contemplado para fase posterior.
- Integración con pipelines de CI/CD automatizados.
- Alta disponibilidad y balanceo de carga.

---

## Componentes del sistema

| Componente | Tecnología | Puerto interno |
|---|---|---|
| Frontend | Next.js (Node.js LTS) | 3000 |
| Backend | NestJS (Node.js LTS) | 3001 |
| Base de datos | PostgreSQL | 5432 |
| Proxy inverso | Nginx | 80 / 443 |
| Gestor de procesos | PM2 | — |

**Nota sobre el frontend**: Next.js se despliega con App Router. El SSR
está limitado al layout y la navegación. Todos los datos del expediente
(hechos, pruebas, riesgos, estrategia, conclusión) se cargan exclusivamente
desde Client Components — nunca en la respuesta HTML inicial.
Esta restricción tiene fundamento en confidencialidad jurídica y está
definida en `docs/07_frontend/ARQUITECTURA_FRONTEND.md`. Infraestructura
no debe asumir ni configurar SSR de datos sensibles del caso.

---

## Requisitos de la VM

### Hardware mínimo para MVP

| Recurso | Mínimo | Recomendado |
|---|---|---|
| CPU | 2 vCPU | 4 vCPU |
| RAM | 4 GB | 8 GB |
| Disco | 40 GB SSD | 80 GB SSD |
| Red | 100 Mbps | 1 Gbps |

### Sistema operativo

Ubuntu Server 24.04 LTS (64-bit).
No se contemplan otras distribuciones en el MVP.

### Software requerido

| Software | Versión | Notas |
|---|---|---|
| Node.js | LTS activo (≥ 20) | Instalar con `nvm` |
| npm | Incluido con Node.js | — |
| PostgreSQL | 16 | Via repositorio oficial |
| Nginx | Estable | Via `apt` |
| PM2 | Última estable | Via `npm install -g pm2` |
| Certbot | Última estable | Para certificados SSL |
| Git | Disponible en Ubuntu | Para clonar el repositorio |

---

## Variables de entorno

Todas las variables de entorno viven en el servidor — nunca en el código
fuente ni en el repositorio. Ninguna clave de API, secreto ni cadena de
conexión se versiona en Git.

Crear los archivos `.env` correspondientes antes del primer arranque.

### Backend — `/opt/lexpenal/backend/.env`

```env
# ── Entorno ───────────────────────────────────────
NODE_ENV=production
PORT=3001

# ── Base de datos ─────────────────────────────────
DATABASE_URL=postgresql://lexpenal_user:CONTRASEÑA@localhost:5432/lexpenal_db

# ── Autenticación JWT ─────────────────────────────
JWT_SECRET=SECRETO_LARGO_Y_ALEATORIO_MIN_64_CHARS
JWT_EXPIRY=8h
SESSION_COOKIE_SECRET=SECRETO_COOKIE_DIFERENTE_AL_JWT
# Esquema híbrido de autenticación:
#   - Cookie HttpOnly: usada por el middleware de Next.js para proteger rutas
#     y rehidratar el token en Server Components de layout.
#   - Bearer token: usado por Client Components en todas las llamadas al backend.
# Las dos variables anteriores son distintas e independientes.
# Coherente con CONTRATO_API.md y ARQUITECTURA_FRONTEND.md.

# ── Módulo de IA ──────────────────────────────────
IA_PROVEEDOR=anthropic
IA_MODELO=claude-sonnet-4-20250514
IA_API_KEY=sk-ant-...
IA_TIMEOUT_MS=30000
IA_MAX_REINTENTOS=1
IA_MAX_TOKENS_RESPUESTA=1000
IA_VENTANA_IDEMPOTENCIA_MIN=5

# ── Almacenamiento de archivos ────────────────────
STORAGE_PATH=/opt/lexpenal/storage
STORAGE_MAX_FILE_SIZE_MB=20

# ── URLs ──────────────────────────────────────────
FRONTEND_URL=https://lexpenal.dominio.com
```

### Frontend — `/opt/lexpenal/frontend/.env.local`

```env
# ── Entorno ───────────────────────────────────────
NODE_ENV=production
PORT=3000

# ── API ───────────────────────────────────────────
NEXT_PUBLIC_API_URL=https://lexpenal.dominio.com/api/v1
# Esta URL es la que los Client Components usan para llamar al backend.
# Apunta al dominio público — el tráfico pasa por Nginx que lo redirige
# internamente a localhost:3001. No usar URL interna (localhost:3001) aquí:
# el navegador del usuario no tiene acceso directo al puerto del backend.

# ── Nota de seguridad ─────────────────────────────
# Variables con prefijo NEXT_PUBLIC_ son visibles en el cliente.
# Nunca usar NEXT_PUBLIC_ para claves de API, tokens ni secretos.
```

**Regla de seguridad**: el frontend no tiene acceso a `IA_API_KEY` ni a
`JWT_SECRET`. La separación de archivos `.env` entre frontend y backend
garantiza que el proceso de Next.js nunca exponga credenciales de servidor.

---

## Hardening del sistema operativo

Aplicar antes de iniciar la instalación de los componentes de la aplicación.

### Usuario de despliegue

```bash
# Crear usuario no root para la aplicación
sudo adduser lexpenal
sudo usermod -aG sudo lexpenal

# Toda la instalación de la aplicación se realiza con este usuario,
# no con root. El directorio /opt/lexpenal debe ser propiedad de este usuario.
sudo mkdir -p /opt/lexpenal
sudo chown lexpenal:lexpenal /opt/lexpenal
```

### Acceso SSH

```bash
# Deshabilitar login root por contraseña y forzar autenticación por clave
sudo nano /etc/ssh/sshd_config
# Ajustar:
#   PermitRootLogin no
#   PasswordAuthentication no
#   PubkeyAuthentication yes

sudo systemctl restart ssh
```

Antes de deshabilitar la autenticación por contraseña, verificar que
la clave pública del administrador está en `~/.ssh/authorized_keys`.

### Firewall

```bash
# Habilitar UFW y permitir solo los puertos necesarios
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh        # puerto 22
sudo ufw allow http       # puerto 80 (Nginx — redirige a HTTPS)
sudo ufw allow https      # puerto 443 (Nginx — tráfico de la app)
sudo ufw enable

# PostgreSQL (5432) y puertos de app (3000, 3001) NO se abren al exterior.
# Solo Nginx recibe tráfico externo; los servicios internos se comunican
# por localhost únicamente.
sudo ufw status
```

---

## Proceso de instalación

### 1. Preparar el servidor

```bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias base
sudo apt install -y git curl build-essential

# Instalar nvm y Node.js LTS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts

# Instalar PM2 globalmente
npm install -g pm2

# Verificar versiones
node --version
npm --version
pm2 --version
```

---

### 2. Instalar PostgreSQL

```bash
# Instalar PostgreSQL 16
sudo apt install -y postgresql postgresql-contrib

# Iniciar y habilitar el servicio
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Crear usuario y base de datos
sudo -u postgres psql << 'SQL'
CREATE USER lexpenal_user WITH PASSWORD 'CONTRASEÑA_SEGURA';
CREATE DATABASE lexpenal_db OWNER lexpenal_user;
GRANT ALL PRIVILEGES ON DATABASE lexpenal_db TO lexpenal_user;
SQL
```

---

### 3. Instalar Nginx

```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

### 4. Clonar el repositorio

```bash
# Crear directorio de la aplicación
sudo mkdir -p /opt/lexpenal
sudo chown $USER:$USER /opt/lexpenal

# Clonar el repositorio
cd /opt/lexpenal
git clone https://github.com/[org]/lexpenal.git .
```

---

### 5. Instalar dependencias y construir

```bash
# Backend
# 1. Instalar dependencias completas (incluyendo devDependencies para compilar TypeScript)
cd /opt/lexpenal/backend
npm ci

# 2. Compilar TypeScript → dist/
npm run build

# 3. Eliminar dependencias de desarrollo post-compilación
npm prune --production
# Resultado: node_modules solo con dependencias de producción,
# dist/ con el código compilado listo para PM2.

# Ejecutar migraciones de base de datos
# El comando exacto depende del ORM elegido (ADR-006 pendiente):
# TypeORM: npm run migration:run
# Prisma:  npx prisma migrate deploy

# Frontend
cd /opt/lexpenal/frontend
npm ci
npm run build
```

---

### 6. Configurar variables de entorno

```bash
# Backend
cp /opt/lexpenal/backend/.env.example /opt/lexpenal/backend/.env
nano /opt/lexpenal/backend/.env
# Completar todos los valores requeridos

# Frontend
cp /opt/lexpenal/frontend/.env.example /opt/lexpenal/frontend/.env.local
nano /opt/lexpenal/frontend/.env.local
# Completar todos los valores requeridos

# Proteger los archivos de entorno
chmod 600 /opt/lexpenal/backend/.env
chmod 600 /opt/lexpenal/frontend/.env.local
```

---

### 7. Configurar PM2

Crear el archivo de ecosistema de PM2:

```bash
cat > /opt/lexpenal/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'lexpenal-backend',
      cwd: '/opt/lexpenal/backend',
      script: 'dist/main.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
      },
    },
    {
      name: 'lexpenal-frontend',
      cwd: '/opt/lexpenal/frontend',
      script: 'node_modules/.bin/next',
      args: 'start',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
      },
    },
  ],
};
EOF
```

Arrancar los procesos:

```bash
cd /opt/lexpenal
pm2 start ecosystem.config.js
pm2 save
pm2 startup  # seguir las instrucciones que imprime para habilitar arranque automático
```

---

### 8. Configurar Nginx

Crear la configuración del sitio:

```bash
sudo nano /etc/nginx/sites-available/lexpenal
```

```nginx
server {
    listen 80;
    server_name lexpenal.dominio.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name lexpenal.dominio.com;

    ssl_certificate     /etc/letsencrypt/live/lexpenal.dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/lexpenal.dominio.com/privkey.pem;

    # Seguridad TLS
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;

    # Headers de seguridad
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;

    # Límite de tamaño de cuerpo (uploads de documentos)
    client_max_body_size 25M;

    # Backend — rutas de la API
    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 60s;  # margen para llamadas al módulo de IA
    }

    # Frontend — todo lo demás
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Activar el sitio:

```bash
sudo ln -s /etc/nginx/sites-available/lexpenal /etc/nginx/sites-enabled/
sudo nginx -t          # verificar configuración
sudo systemctl reload nginx
```

---

### 9. Obtener certificado SSL

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d lexpenal.dominio.com
# Seguir el asistente interactivo
# Certbot configura la renovación automática
```

---

### 10. Directorio de almacenamiento

```bash
# Crear directorio para archivos generados (informes, documentos)
sudo mkdir -p /opt/lexpenal/storage
sudo chown -R $USER:$USER /opt/lexpenal/storage
chmod 750 /opt/lexpenal/storage
```

> **Advertencia — punto único de falla**: en el MVP el almacenamiento
> de archivos es local en la misma VM. Si el servidor falla, los archivos
> generados se pierden junto con la base de datos. El directorio `/opt/lexpenal/storage`
> **requiere backup diario obligatorio** (ver sección Política de respaldo).
> Para producción con usuarios reales, evaluar migración a almacenamiento
> externo (S3 o equivalente) antes del lanzamiento.

---

## Política de respaldo

### Base de datos

```bash
# Backup diario de PostgreSQL con retención de 30 días
# Crear script de backup
sudo nano /opt/lexpenal/scripts/backup_db.sh
```

```bash
#!/bin/bash
FECHA=$(date +%Y%m%d_%H%M%S)
DESTINO=/opt/lexpenal/backups/db
mkdir -p "$DESTINO"

pg_dump -U lexpenal_user lexpenal_db | gzip > "$DESTINO/lexpenal_$FECHA.sql.gz"

# Eliminar backups con más de 30 días
find "$DESTINO" -name "*.sql.gz" -mtime +30 -delete
```

```bash
chmod +x /opt/lexpenal/scripts/backup_db.sh

# Programar ejecución diaria a las 02:00
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/lexpenal/scripts/backup_db.sh") | crontab -
```

### Almacenamiento de archivos

```bash
# Backup diario del directorio storage con retención de 30 días
sudo nano /opt/lexpenal/scripts/backup_storage.sh
```

```bash
#!/bin/bash
FECHA=$(date +%Y%m%d_%H%M%S)
DESTINO=/opt/lexpenal/backups/storage
mkdir -p "$DESTINO"

tar -czf "$DESTINO/storage_$FECHA.tar.gz" /opt/lexpenal/storage

find "$DESTINO" -name "*.tar.gz" -mtime +30 -delete
```

```bash
chmod +x /opt/lexpenal/scripts/backup_storage.sh

# Programar ejecución diaria a las 02:30
(crontab -l 2>/dev/null; echo "30 2 * * * /opt/lexpenal/scripts/backup_storage.sh") | crontab -
```

### Reglas de respaldo

| Elemento | Frecuencia | Retención | Destino recomendado |
|---|---|---|---|
| Base de datos PostgreSQL | Diaria (02:00) | 30 días | `/opt/lexpenal/backups/db` + copia externa |
| Archivos de storage | Diaria (02:30) | 30 días | `/opt/lexpenal/backups/storage` + copia externa |

> **Advertencia**: los backups en la misma VM no protegen contra fallo
> total del servidor. Para un despliegue productivo, copiar los backups
> a almacenamiento externo (S3, NFS, servidor remoto) es obligatorio.

### Prueba de restauración

Realizar prueba de restauración periódica (mínimo mensual):

```bash
# Restaurar backup de base de datos en entorno de prueba
gunzip -c /opt/lexpenal/backups/db/lexpenal_FECHA.sql.gz | \
  psql -U lexpenal_user lexpenal_db_test
```

Una copia de seguridad que nunca se prueba no es una copia de seguridad confiable.

---

## Verificaciones post-instalación

Ejecutar estas verificaciones antes de entregar el sistema a los primeros usuarios.

### Verificaciones de servicio

```bash
# Estado de procesos PM2
pm2 status

# Logs de arranque
pm2 logs lexpenal-backend --lines 50
pm2 logs lexpenal-frontend --lines 50

# PostgreSQL
sudo systemctl status postgresql

# Nginx
sudo systemctl status nginx
sudo nginx -t
```

### Verificaciones funcionales mínimas

| Verificación | Cómo | Resultado esperado |
|---|---|---|
| HTTPS activo | Abrir `https://lexpenal.dominio.com` en navegador | Página de login sin advertencia SSL |
| HTTP redirige a HTTPS | Abrir `http://lexpenal.dominio.com` | Redirección automática a HTTPS |
| Login funciona | Ingresar con usuario administrador | Acceso al dashboard |
| API responde | `curl https://lexpenal.dominio.com/api/v1/auth/session` | `401` (esperado sin cookie) |
| Base de datos conectada | Revisar logs del backend — sin errores de conexión | Sin errores de PostgreSQL en logs |
| Módulo de IA responde | Desde el sistema, ejecutar una consulta de IA en cualquier herramienta | Respuesta del asistente o `503` si la API key no está configurada |
| Generación de informe | Generar un `resumen_ejecutivo` de prueba | Archivo descargable generado |
| Transición inválida rechazada | Intentar una transición no permitida vía API | `409` si el estado no permite la transición; `422` si falla una regla de guardia |
| `pendiente_revision` en solo lectura | Enviar caso a revisión e intentar editar una herramienta | Backend rechaza la escritura; `/review` disponible para supervisor |

### Verificaciones de seguridad

```bash
# El archivo .env no debe ser accesible por Nginx
curl https://lexpenal.dominio.com/.env
# Resultado esperado: 404 (Nginx no debe servir archivos fuera de /api/ y /)

# Verificar que los headers de seguridad están presentes
curl -I https://lexpenal.dominio.com
# Debe incluir: Strict-Transport-Security, X-Frame-Options, X-Content-Type-Options
```

---

## Actualización del sistema

Para actualizar a una nueva versión del código:

```bash
cd /opt/lexpenal

# 1. Obtener los cambios
git pull origin main

# 2. Instalar dependencias nuevas si las hay
cd backend && npm ci --production && cd ..
cd frontend && npm ci && npm run build && cd ..

# 3. Ejecutar migraciones de base de datos si las hay
cd backend
# TypeORM: npm run migration:run
# Prisma:  npx prisma migrate deploy
cd ..

# 4. Reiniciar procesos
pm2 restart all

# 5. Verificar estado
pm2 status
pm2 logs --lines 30
```

---

## Decisiones pendientes que afectan este documento

| Decisión | ADR | Impacto en despliegue |
|---|---|---|
| ORM (TypeORM vs Prisma) | ADR-006 *(pendiente)* | Cambia el comando de migración en pasos 5 y actualización |
| Estrategia de autenticación (JWT simple vs refresh token) | ADR-007 *(pendiente)* | Puede requerir variables de entorno adicionales para refresh token |
| Almacenamiento de archivos (local vs S3 o equivalente) | Sin ADR todavía | En MVP se usa almacenamiento local en `/opt/lexpenal/storage`; producción real requiere decidir si migra a almacenamiento externo |

Cuando se cierren ADR-006 y ADR-007, este documento debe revisarse
para actualizar los comandos afectados.
