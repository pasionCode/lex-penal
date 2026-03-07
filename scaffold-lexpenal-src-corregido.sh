#!/usr/bin/env bash
# =============================================================================
# scaffold-lexpenal-src.sh
# Toque canónico del src/ de LexPenal backend (NestJS + TypeScript)
# Canon: MODELO_DATOS_v3 · CONTRATO_API_v4 · ARQUITECTURA_MODULO_IA_v3
#        REGLAS_FUNCIONALES_VINCULANTES · MATRIZ_REQUISITOS · CRITERIOS_QA
#
# Lo que hace:
#   - Crea estructura de directorios y archivos stub
#   - Deja firmas correctas con 'not implemented'
#   - No escribe lógica de negocio
#   - No instala dependencias
#   - No genera schema.prisma (segunda pasada)
#
# Uso:
#   chmod +x scaffold-lexpenal-src.sh
#   ./scaffold-lexpenal-src.sh [ruta-destino]
#   Por defecto crea ./src/ en el directorio actual
# =============================================================================

set -euo pipefail

FORCE=0
ROOT=""

usage() {
  cat <<'USAGE'
Uso:
  ./scaffold-lexpenal-src.sh [--force] [ruta-destino]

Opciones:
  --force   Sobrescribe archivos existentes que difieran del scaffold.
            Antes de sobrescribir, crea backup en .lexpenal_backup/<timestamp>/
USAGE
}

while (($#)); do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -n "$ROOT" ]]; then
        echo "Error: solo se admite una ruta de destino." >&2
        usage >&2
        exit 1
      fi
      ROOT="$1"
      shift
      ;;
  esac
done

ROOT=${ROOT:-"./src"}
BACKUP_STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$ROOT/.lexpenal_backup/$BACKUP_STAMP"
RUN_WRITTEN="$(mktemp)"
trap 'rm -f "$RUN_WRITTEN"' EXIT

created=0
updated=0
unchanged=0
skipped=0
backed_up=0

echo "▶  Generando estructura canónica en: $ROOT"
[[ "$FORCE" -eq 1 ]] && echo "▶  Modo: sobrescritura segura activada (--force)" || echo "▶  Modo: seguro (no sobrescribe archivos distintos)"
echo ""

# -----------------------------------------------------------------------------
# Utilidades
# -----------------------------------------------------------------------------
mkf() {
  local rel="$1"
  local path="$ROOT/$rel"
  local tmp
  tmp="$(mktemp)"

  mkdir -p "$(dirname "$path")"
  cat > "$tmp"

  if [[ -f "$path" ]]; then
    if cmp -s "$tmp" "$path"; then
      rm -f "$tmp"
      echo "  =  $rel"
      unchanged=$((unchanged + 1))
      return 0
    fi

    if grep -Fxq "$rel" "$RUN_WRITTEN"; then
      mv "$tmp" "$path"
      echo "  ↺  $rel"
      updated=$((updated + 1))
      return 0
    fi

    if [[ "$FORCE" -eq 1 ]]; then
      local backup_path="$BACKUP_DIR/$rel"
      mkdir -p "$(dirname "$backup_path")"
      cp "$path" "$backup_path"
      backed_up=$((backed_up + 1))
      mv "$tmp" "$path"
      echo "  ↺  $rel"
      updated=$((updated + 1))
      printf '%s
' "$rel" >> "$RUN_WRITTEN"
      return 0
    fi

    rm -f "$tmp"
    echo "  !  $rel (existe y difiere; use --force para sobrescribir)"
    skipped=$((skipped + 1))
    return 0
  fi

  mv "$tmp" "$path"
  printf '%s
' "$rel" >> "$RUN_WRITTEN"
  echo "  ✓  $rel"
  created=$((created + 1))
}

mkd() {
  local rel="$1"
  mkdir -p "$ROOT/$rel"
  echo "  ✓  $rel/"
}

mkplaceholder() {
  mkf "$1/.gitkeep" <<'EOF'
EOF
}

# =============================================================================
# CAPA TRANSVERSAL
# =============================================================================
echo "── Transversal ──────────────────────────────────────────"

mkf "common/guards/jwt-auth.guard.ts" <<'EOF'
import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';

/**
 * Guard de autenticación JWT.
 * Valida el token de sesión en cookie HttpOnly o header Authorization.
 * ADR-007: JWT simple, 8h, sin refresh token en MVP.
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  canActivate(_context: ExecutionContext): boolean {
    throw new Error('not implemented');
  }
}
EOF

mkf "common/guards/roles.guard.ts" <<'EOF'
import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';

/**
 * Guard de autorización por perfil.
 * Perfiles: estudiante | supervisor | administrador
 * Requiere JwtAuthGuard aplicado previamente.
 */
@Injectable()
export class RolesGuard implements CanActivate {
  canActivate(_context: ExecutionContext): boolean {
    throw new Error('not implemented');
  }
}
EOF

mkf "common/decorators/current-user.decorator.ts" <<'EOF'
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/**
 * Extrae el usuario autenticado del request.
 * Requiere JwtAuthGuard activo en la ruta.
 */
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext) => {
    throw new Error('not implemented');
  },
);
EOF

mkf "common/decorators/roles.decorator.ts" <<'EOF'
import { SetMetadata } from '@nestjs/common';

export type UserRole = 'estudiante' | 'supervisor' | 'administrador';
export const ROLES_KEY = 'roles';

/** Declara los perfiles autorizados para una ruta. */
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
EOF

mkf "common/interceptors/audit.interceptor.ts" <<'EOF'
import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';

/**
 * Interceptor de auditoría transversal.
 * Registra eventos críticos en eventos_auditoria (R06).
 * Las operaciones críticas sin registro de auditoría deben fallar.
 */
@Injectable()
export class AuditInterceptor implements NestInterceptor {
  intercept(_context: ExecutionContext, next: CallHandler): Observable<unknown> {
    throw new Error('not implemented');
  }
}
EOF

mkf "common/filters/http-exception.filter.ts" <<'EOF'
import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
} from '@nestjs/common';
import { Response } from 'express';

/**
 * Filtro global de excepciones HTTP.
 * Normaliza errores al formato { error: string, mensaje: string }.
 * 409 → transición de estado inválida desde el estado actual.
 * 422 → guarda de negocio fallida (checklist, revisión, conclusión).
 * 503 → proveedor de IA no disponible.
 */
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(_exception: HttpException, _host: ArgumentsHost): void {
    throw new Error('not implemented');
  }
}
EOF

# -----------------------------------------------------------------------------
mkf "config/app.config.ts" <<'EOF'
/**
 * Configuración general de la aplicación.
 * Todas las variables de entorno se leen aquí, nunca en servicios.
 */
export const appConfig = () => ({
  port: parseInt(process.env.PORT ?? '3001', 10),
  nodeEnv: process.env.NODE_ENV ?? 'development',
});
EOF

mkf "config/database.config.ts" <<'EOF'
/** Configuración de conexión a PostgreSQL vía Prisma (ADR-002, ADR-006). */
export const databaseConfig = () => ({
  databaseUrl: process.env.DATABASE_URL,
});
EOF

mkf "config/jwt.config.ts" <<'EOF'
/**
 * Configuración JWT (ADR-007).
 * Token 8h. Cookie HttpOnly + Bearer. Sin refresh token en MVP.
 */
export const jwtConfig = () => ({
  secret: process.env.JWT_SECRET,
  expiresIn: process.env.JWT_EXPIRES_IN ?? '8h',
});
EOF

mkf "config/ai.config.ts" <<'EOF'
/**
 * Configuración del módulo de IA (ADR-004).
 * El proveedor, modelo y credenciales se leen siempre desde variables de entorno.
 * El nombre del modelo nunca aparece en código fuente (RI-IA-06).
 */
export const aiConfig = () => ({
  provider: process.env.IA_PROVIDER ?? 'anthropic',
  model: process.env.IA_MODEL,
  apiKey: process.env.IA_API_KEY,
  maxTokens: parseInt(process.env.IA_MAX_TOKENS ?? '1000', 10),
  timeoutMs: parseInt(process.env.IA_TIMEOUT_MS ?? '30000', 10),
});
EOF

# -----------------------------------------------------------------------------
mkf "contracts/api-response.ts" <<'EOF'
/** Envoltorio estándar de respuesta de la API. */
export interface ApiResponse<T> {
  data: T;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  per_page: number;
}

export interface ApiError {
  error: string;
  mensaje: string;
  detalles?: string[];
}
EOF

mkf "contracts/pagination.ts" <<'EOF'
/** Parámetros de paginación compartidos. */
export interface PaginationParams {
  page?: number;
  per_page?: number;
}
EOF

# -----------------------------------------------------------------------------
mkf "types/enums.ts" <<'EOF'
/**
 * Enums canónicos del dominio LexPenal.
 * Fuente: MODELO_DATOS_v3.md
 */

export enum EstadoCaso {
  BORRADOR = 'borrador',
  EN_ANALISIS = 'en_analisis',
  PENDIENTE_REVISION = 'pendiente_revision',
  DEVUELTO = 'devuelto',
  APROBADO_SUPERVISOR = 'aprobado_supervisor',
  LISTO_PARA_CLIENTE = 'listo_para_cliente',
  CERRADO = 'cerrado',
}

export enum PerfilUsuario {
  ESTUDIANTE = 'estudiante',
  SUPERVISOR = 'supervisor',
  ADMINISTRADOR = 'administrador',
}

export enum SituacionLibertad {
  LIBRE = 'libre',
  DETENIDO = 'detenido',
}

export enum EstadoHecho {
  ACREDITADO = 'acreditado',
  REFERIDO = 'referido',
  DISCUTIDO = 'discutido',
}

export enum IncidenciaJuridica {
  TIPICIDAD = 'tipicidad',
  ANTIJURIDICIDAD = 'antijuridicidad',
  CULPABILIDAD = 'culpabilidad',
  PROCEDIMIENTO = 'procedimiento',
}

export enum TipoPrueba {
  TESTIMONIAL = 'testimonial',
  DOCUMENTAL = 'documental',
  PERICIAL = 'pericial',
  REAL = 'real',
  OTRO = 'otro',
}

export enum EvaluacionProbatoria {
  OK = 'ok',
  CUESTIONABLE = 'cuestionable',
  DEFICIENTE = 'deficiente',
}

export enum Probabilidad {
  ALTA = 'alta',
  MEDIA = 'media',
  BAJA = 'baja',
}

export enum Impacto {
  ALTO = 'alto',
  MEDIO = 'medio',
  BAJO = 'bajo',
}

export enum Prioridad {
  CRITICA = 'critica',
  ALTA = 'alta',
  MEDIA = 'media',
  BAJA = 'baja',
}

export enum EstadoMitigacion {
  PENDIENTE = 'pendiente',
  EN_CURSO = 'en_curso',
  MITIGADO = 'mitigado',
  ACEPTADO = 'aceptado',
}

export enum ResultadoRevision {
  APROBADO = 'aprobado',
  DEVUELTO = 'devuelto',
}

export enum TipoInforme {
  RESUMEN_EJECUTIVO = 'resumen_ejecutivo',
  CONCLUSION_OPERATIVA = 'conclusion_operativa',
  CONTROL_CALIDAD = 'control_calidad',
  RIESGOS = 'riesgos',
  CRONOLOGICO = 'cronologico',
  REVISION_SUPERVISOR = 'revision_supervisor',
  AGENDA_VENCIMIENTOS = 'agenda_vencimientos',
}

export enum FormatoInforme {
  PDF = 'pdf',
  DOCX = 'docx',
}

export enum EstadoLlamadaIA {
  EXITOSA = 'exitosa',
  FALLIDA = 'fallida',
  TIMEOUT = 'timeout',
}

export enum ResultadoAuditoria {
  EXITOSO = 'exitoso',
  RECHAZADO = 'rechazado',
}

/**
 * Valores canónicos del campo herramienta en POST /api/v1/ai/query.
 * Coinciden exactamente con los subrecursos del contrato API (kebab-case).
 */
export enum HerramientaIA {
  BASIC_INFO = 'basic-info',
  FACTS = 'facts',
  EVIDENCE = 'evidence',
  RISKS = 'risks',
  STRATEGY = 'strategy',
  CLIENT_BRIEFING = 'client-briefing',
  CHECKLIST = 'checklist',
  CONCLUSION = 'conclusion',
}
EOF

mkf "types/interfaces.ts" <<'EOF'
/**
 * Interfaces de dominio compartidas.
 * Fuente: MODELO_DATOS_v3.md · CONTRATO_API_v4.md
 */

export interface UsuarioAutenticado {
  id: string;
  email: string;
  perfil: string;
  nombre: string;
}

export interface IAContexto {
  caso: {
    radicado: string;
    delito_imputado: string;
    etapa_procesal: string;
    regimen_procesal: string;
  };
  herramienta: string;
  datos: Record<string, unknown>;
}

export interface IARespuesta {
  contenido: string;
  tokens_entrada: number;
  tokens_salida: number;
  modelo_usado: string;
  duracion_ms: number;
}
EOF

# =============================================================================
# INFRAESTRUCTURA
# =============================================================================
echo ""
echo "── Infraestructura ──────────────────────────────────────"

mkf "infrastructure/database/prisma/prisma.module.ts" <<'EOF'
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

/**
 * Módulo global de Prisma.
 * @Global permite que PrismaService esté disponible en todos los módulos
 * sin importación explícita. (ADR-006)
 */
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
EOF

mkf "infrastructure/database/prisma/prisma.service.ts" <<'EOF'
import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

/**
 * Servicio de conexión a PostgreSQL vía Prisma ORM (ADR-006).
 * Fuente canónica de persistencia: MODELO_DATOS_v3.md
 */
@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  async onModuleInit(): Promise<void> {
    await this.$connect();
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }
}
EOF

mkf "infrastructure/database/prisma/transaction.helper.ts" <<'EOF'
import { PrismaClient } from '@prisma/client';
import { PrismaService } from './prisma.service';

/**
 * Helper de transacciones Prisma.
 * Uso obligatorio en operaciones atómicas, por ejemplo:
 * - Transición de estado + creación de estructura base (R08)
 * - Registro de auditoría atómico con la operación crítica (R06)
 */
export async function withTransaction<T>(
  prisma: PrismaService,
  fn: (tx: PrismaClient) => Promise<T>,
): Promise<T> {
  return prisma.$transaction((tx) => fn(tx));
}
EOF

# -----------------------------------------------------------------------------
mkf "infrastructure/ai/providers/ia-provider.adapter.ts" <<'EOF'
import { IAContexto, IARespuesta } from '../../../types/interfaces';

/**
 * Contrato común para adaptadores de proveedor de IA (ADR-004, R07).
 * Toda implementación debe respetar esta interfaz.
 * Añadir un proveedor = implementar esta interfaz, sin tocar IAService.
 */
export interface IAPayload {
  sistema: string;
  mensajes: { rol: 'usuario' | 'asistente'; contenido: string }[];
  modelo: string;
  max_tokens: number;
}

export abstract class IAProviderAdapter {
  abstract consultar(payload: IAPayload, contexto: IAContexto): Promise<IARespuesta>;
}
EOF

mkf "infrastructure/ai/providers/anthropic.adapter.ts" <<'EOF'
import { Injectable } from '@nestjs/common';
import { IAContexto, IARespuesta } from '../../../types/interfaces';
import { IAPayload, IAProviderAdapter } from './ia-provider.adapter';

/**
 * Adaptador Anthropic — proveedor por defecto del MVP (ADR-004).
 * El modelo se lee siempre desde ia.config, nunca del código fuente (RI-IA-06).
 * Los parámetros operativos (timeout, reintentos) los hereda de la política central.
 */
@Injectable()
export class AnthropicAdapter extends IAProviderAdapter {
  async consultar(_payload: IAPayload, _contexto: IAContexto): Promise<IARespuesta> {
    throw new Error('not implemented');
  }
}
EOF

# =============================================================================
# MÓDULOS — helpers internos
# =============================================================================

# Genera estructura estándar de un módulo con repositorio
scaffold_module() {
  local name="$1"        # kebab-case del módulo
  local pascal="$2"      # PascalCase
  local has_repo="${3:-true}"
  local dtos="${4:-}"    # nombres adicionales de DTOs separados por espacio

  local dir="modules/$name"

  mkf "$dir/${name}.module.ts" <<EOF
import { Module } from '@nestjs/common';
import { ${pascal}Controller } from './${name}.controller';
import { ${pascal}Service } from './${name}.service';
$([ "$has_repo" = "true" ] && echo "import { ${pascal}Repository } from './${name}.repository';")

@Module({
  controllers: [${pascal}Controller],
  providers: [
    ${pascal}Service,
$([ "$has_repo" = "true" ] && echo "    ${pascal}Repository,")
  ],
  exports: [${pascal}Service],
})
export class ${pascal}Module {}
EOF

  mkf "$dir/${name}.controller.ts" <<EOF
import { Controller } from '@nestjs/common';
import { ${pascal}Service } from './${name}.service';

/** Controlador de ${name}. Delega toda lógica a ${pascal}Service. */
@Controller()
export class ${pascal}Controller {
  constructor(private readonly service: ${pascal}Service) {}
}
EOF

  mkf "$dir/${name}.service.ts" <<EOF
import { Injectable } from '@nestjs/common';
$([ "$has_repo" = "true" ] && echo "import { ${pascal}Repository } from './${name}.repository';")

/** Servicio de ${name}. Orquesta la lógica de negocio del módulo. */
@Injectable()
export class ${pascal}Service {
$([ "$has_repo" = "true" ] && echo "  constructor(private readonly repository: ${pascal}Repository) {}")
}
EOF

  if [ "$has_repo" = "true" ]; then
    mkf "$dir/${name}.repository.ts" <<EOF
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';

/**
 * Repositorio de ${name}.
 * Único punto de acceso a la persistencia del módulo.
 * Depende de PrismaService (ADR-006).
 */
@Injectable()
export class ${pascal}Repository {
  constructor(private readonly prisma: PrismaService) {}
}
EOF
  fi

  mkdir -p "$ROOT/$dir/dto"
  touch "$ROOT/$dir/dto/.gitkeep"
}

# Genera un DTO stub
scaffold_dto() {
  local module="$1"  # kebab-case
  local pascal="$2"  # PascalCase del módulo
  local dto_name="$3" # kebab-case del dto (sin .dto.ts)
  local dto_pascal="$4" # PascalCase del dto

  mkf "modules/${module}/dto/${dto_name}.dto.ts" <<EOF
/** DTO: ${dto_pascal}. Validar con class-validator antes de implementar. */
export class ${dto_pascal}Dto {}
EOF
}

# =============================================================================
# MÓDULO: auth
# =============================================================================
echo ""
echo "── Módulos ──────────────────────────────────────────────"

mkf "modules/auth/auth.module.ts" <<'EOF'
import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

/**
 * Módulo de autenticación y sesión (ADR-007).
 * JWT 8h · Cookie HttpOnly + Bearer · Sin refresh token en MVP.
 * Endpoints: POST /auth/login · POST /auth/logout · GET /auth/session
 */
@Module({
  controllers: [AuthController],
  providers: [AuthService],
  exports: [AuthService],
})
export class AuthModule {}
EOF

mkf "modules/auth/auth.controller.ts" <<'EOF'
import { Body, Controller, Get, Post, Res } from '@nestjs/common';
import { Response } from 'express';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { SessionResponseDto } from './dto/session-response.dto';

/** POST /api/v1/auth/login · POST /api/v1/auth/logout · GET /api/v1/auth/session */
@Controller('api/v1/auth')
export class AuthController {
  constructor(private readonly service: AuthService) {}

  @Post('login')
  login(@Body() _dto: LoginDto, @Res() _res: Response): Promise<void> {
    throw new Error('not implemented');
  }

  @Post('logout')
  logout(@Res() _res: Response): Promise<void> {
    throw new Error('not implemented');
  }

  @Get('session')
  session(): Promise<SessionResponseDto> {
    throw new Error('not implemented');
  }
}
EOF

mkf "modules/auth/auth.service.ts" <<'EOF'
import { Injectable } from '@nestjs/common';

/**
 * Servicio de autenticación.
 * Valida credenciales, emite JWT, invalida sesión.
 * Un usuario desactivado no puede iniciar sesión (MODELO_DATOS_v3 — usuarios.activo).
 */
@Injectable()
export class AuthService {
  login(_email: string, _password: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  logout(_token: string): Promise<void> {
    throw new Error('not implemented');
  }

  validateToken(_token: string): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF

mkf "modules/auth/dto/login.dto.ts" <<'EOF'
/** Credenciales de acceso al sistema. */
export class LoginDto {
  email!: string;
  password!: string;
}
EOF

mkf "modules/auth/dto/session-response.dto.ts" <<'EOF'
/** Datos del usuario autenticado retornados por GET /auth/session. */
export class SessionResponseDto {
  id!: string;
  nombre!: string;
  email!: string;
  perfil!: string;
}
EOF

# =============================================================================
# MÓDULO: users
# =============================================================================
scaffold_module "users" "Users"

mkf "modules/users/users.controller.ts" <<'EOF'
import { Body, Controller, Get, Param, Post, Put, Query } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { QueryUsersDto } from './dto/query-users.dto';
import { UpdateUserDto } from './dto/update-user.dto';

/**
 * GET    /api/v1/users
 * POST   /api/v1/users
 * GET    /api/v1/users/:id
 * PUT    /api/v1/users/:id
 * Acceso: solo Administrador (perfiles y activación).
 */
@Controller('api/v1/users')
export class UsersController {
  constructor(private readonly service: UsersService) {}

  @Get()
  findAll(@Query() _query: QueryUsersDto): Promise<unknown> { throw new Error('not implemented'); }

  @Post()
  create(@Body() _dto: CreateUserDto): Promise<unknown> { throw new Error('not implemented'); }

  @Get(':id')
  findOne(@Param('id') _id: string): Promise<unknown> { throw new Error('not implemented'); }

  @Put(':id')
  update(@Param('id') _id: string, @Body() _dto: UpdateUserDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF

mkf "modules/users/dto/create-user.dto.ts" <<'EOF'
import { PerfilUsuario } from '../../../types/enums';

/** Campos requeridos para crear un usuario (MODELO_DATOS_v3 — tabla usuarios). */
export class CreateUserDto {
  nombre!: string;
  email!: string;
  password!: string;
  perfil!: PerfilUsuario;
}
EOF

mkf "modules/users/dto/update-user.dto.ts" <<'EOF'
import { PerfilUsuario } from '../../../types/enums';

/** Campos actualizables de un usuario (perfil, activo). */
export class UpdateUserDto {
  nombre?: string;
  perfil?: PerfilUsuario;
  activo?: boolean;
}
EOF

mkf "modules/users/dto/query-users.dto.ts" <<'EOF'
import { PerfilUsuario } from '../../../types/enums';

/** Filtros de listado de usuarios. */
export class QueryUsersDto {
  perfil?: PerfilUsuario;
  activo?: boolean;
  page?: number;
  per_page?: number;
}
EOF

# =============================================================================
# MÓDULO: clients
# =============================================================================
scaffold_module "clients" "Clients"

mkf "modules/clients/clients.controller.ts" <<'EOF'
import { Body, Controller, Get, Param, Post, Put } from '@nestjs/common';
import { ClientsService } from './clients.service';
import { CreateClientDto } from './dto/create-client.dto';
import { UpdateClientDto } from './dto/update-client.dto';

/**
 * GET    /api/v1/clients
 * POST   /api/v1/clients
 * GET    /api/v1/clients/:id
 * PUT    /api/v1/clients/:id
 * UNIQUE: (tipo_documento, documento) — no duplicar procesados.
 */
@Controller('api/v1/clients')
export class ClientsController {
  constructor(private readonly service: ClientsService) {}

  @Get()
  findAll(): Promise<unknown> { throw new Error('not implemented'); }

  @Post()
  create(@Body() _dto: CreateClientDto): Promise<unknown> { throw new Error('not implemented'); }

  @Get(':id')
  findOne(@Param('id') _id: string): Promise<unknown> { throw new Error('not implemented'); }

  @Put(':id')
  update(@Param('id') _id: string, @Body() _dto: UpdateClientDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF

mkf "modules/clients/dto/create-client.dto.ts" <<'EOF'
import { SituacionLibertad } from '../../../types/enums';

/**
 * DTO de creación de cliente/procesado.
 * situacion_libertad en clientes, NO en client-briefing (MODELO_DATOS_v3).
 * Si detenido, lugar_detencion es obligatorio.
 */
export class CreateClientDto {
  nombre!: string;
  tipo_documento!: string;
  documento!: string;
  contacto?: string;
  situacion_libertad!: SituacionLibertad;
  lugar_detencion?: string;
}
EOF

mkf "modules/clients/dto/update-client.dto.ts" <<'EOF'
import { SituacionLibertad } from '../../../types/enums';

/** Campos actualizables del procesado. */
export class UpdateClientDto {
  nombre?: string;
  tipo_documento?: string;
  documento?: string;
  contacto?: string;
  situacion_libertad?: SituacionLibertad;
  lugar_detencion?: string;
}
EOF

# =============================================================================
# MÓDULO: cases
# =============================================================================
scaffold_module "cases" "Cases"

mkf "modules/cases/cases.controller.ts" <<'EOF'
import { Controller, Get, Post, Put, Param, Body } from '@nestjs/common';
import { CasesService } from './cases.service';
import { CreateCaseDto } from './dto/create-case.dto';
import { TransitionStateDto } from './dto/transition-state.dto';
import { UpdateCaseDto } from './dto/update-case.dto';

/**
 * Agregado raíz del caso:
 * GET    /api/v1/cases
 * POST   /api/v1/cases
 * GET    /api/v1/cases/:id
 * PUT    /api/v1/cases/:id
 * POST   /api/v1/cases/:id/transition
 *
 * Reglas de estado (ADR-003, R08, R09):
 * - borrador → no acepta escritura en herramientas
 * - cerrado  → inmutable en todas las herramientas
 * - Estado solo modificable por CasoEstadoService
 */
@Controller('api/v1/cases')
export class CasesController {
  constructor(private readonly service: CasesService) {}

  @Get()
  findAll(): Promise<unknown> { throw new Error('not implemented'); }

  @Post()
  create(@Body() _dto: CreateCaseDto): Promise<unknown> { throw new Error('not implemented'); }

  @Get(':id')
  findOne(@Param('id') _id: string): Promise<unknown> { throw new Error('not implemented'); }

  @Put(':id')
  update(@Param('id') _id: string, @Body() _dto: UpdateCaseDto): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Post(':id/transition')
  transition(@Param('id') _id: string, @Body() _dto: TransitionStateDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF

mkf "modules/cases/cases.service.ts" <<'EOF'
import { Injectable } from '@nestjs/common';
import { CasesRepository } from './cases.repository';

/**
 * Orquesta CRUD del caso y delega transiciones a CasoEstadoService.
 * R08: al activar (borrador→en_analisis) crea estructura base atómica.
 * R09: cerrado es inmutable — verificar antes de delegar a herramientas.
 */
@Injectable()
export class CasesService {
  constructor(private readonly repository: CasesRepository) {}
}
EOF

mkf "modules/cases/dto/create-case.dto.ts" <<'EOF'
/** Campos mínimos para crear un caso (MODELO_DATOS_v3 — tabla casos). */
export class CreateCaseDto {
  cliente_id!: string;
  radicado!: string;
  delito_imputado!: string;
  regimen_procesal!: string;
  etapa_procesal!: string;
  despacho?: string;
  fecha_apertura?: string;
  agravantes?: string;
  observaciones?: string;
}
EOF

mkf "modules/cases/dto/transition-state.dto.ts" <<'EOF'
import { EstadoCaso } from '../../../types/enums';

/**
 * DTO de transición de estado.
 * 409: la transición no existe desde el estado actual.
 * 422: la transición existe pero falla una guarda de negocio.
 */
export class TransitionStateDto {
  estado_destino!: EstadoCaso;
  observaciones?: string;
}
EOF

mkf "modules/cases/dto/update-case.dto.ts" <<'EOF'
/** Campos actualizables del caso (basic-info y metadata). */
export class UpdateCaseDto {
  despacho?: string;
  etapa_procesal?: string;
  regimen_procesal?: string;
  proxima_actuacion?: string;
  fecha_proxima_actuacion?: string;
  responsable_proxima_actuacion?: string;
  observaciones?: string;
}
EOF

# =============================================================================
# MÓDULOS DE HERRAMIENTAS — patrón uniforme
# Todos son subrecursos de cases en URL, módulos hermanos en código.
# =============================================================================

# facts
scaffold_module "facts" "Facts"
mkf "modules/facts/facts.controller.ts" <<'EOF'
import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { FactsService } from './facts.service';
import { UpdateFactsDto } from './dto/update-facts.dto';

/**
 * GET /api/v1/cases/:id/facts
 * PUT /api/v1/cases/:id/facts  → reemplaza el conjunto completo
 * Solo lectura en pendiente_revision y posteriores (R09 parcial).
 * Campos: descripcion, estado_hecho, fuente, incidencia_juridica (MODELO_DATOS_v3).
 */
@Controller('api/v1/cases/:caseId/facts')
export class FactsController {
  constructor(private readonly service: FactsService) {}

  @Get()
  findAll(@Param('caseId') _caseId: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  replace(@Param('caseId') _caseId: string, @Body() _dto: UpdateFactsDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF
mkf "modules/facts/dto/update-facts.dto.ts" <<'EOF'
import { EstadoHecho, IncidenciaJuridica } from '../../../types/enums';

export class FactItemDto {
  orden!: number;
  descripcion!: string;
  estado_hecho!: EstadoHecho;
  fuente?: string;
  incidencia_juridica?: IncidenciaJuridica;
}

/** PUT reemplaza la lista completa. Omitir un elemento implica eliminarlo. */
export class UpdateFactsDto {
  hechos!: FactItemDto[];
}
EOF

# evidence
scaffold_module "evidence" "Evidence"
mkf "modules/evidence/evidence.controller.ts" <<'EOF'
import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { EvidenceService } from './evidence.service';
import { UpdateEvidenceDto } from './dto/update-evidence.dto';

/**
 * GET /api/v1/cases/:id/evidence
 * PUT /api/v1/cases/:id/evidence → reemplaza el conjunto completo
 * Campos canónicos: descripcion, tipo_prueba, hecho_id,
 * hecho_descripcion_libre, licitud, legalidad, suficiencia,
 * credibilidad, posicion_defensiva (MODELO_DATOS_v3).
 * hecho_id si diligenciado debe pertenecer al mismo caso (integridad cruzada).
 */
@Controller('api/v1/cases/:caseId/evidence')
export class EvidenceController {
  constructor(private readonly service: EvidenceService) {}

  @Get()
  findAll(@Param('caseId') _caseId: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  replace(@Param('caseId') _caseId: string, @Body() _dto: UpdateFactsDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF
mkf "modules/evidence/dto/update-evidence.dto.ts" <<'EOF'
import { EvaluacionProbatoria, TipoPrueba } from '../../../types/enums';

export class EvidenceItemDto {
  descripcion!: string;
  tipo_prueba!: TipoPrueba;
  hecho_id?: string;
  hecho_descripcion_libre?: string;
  licitud!: EvaluacionProbatoria;
  legalidad!: EvaluacionProbatoria;
  suficiencia!: EvaluacionProbatoria;
  credibilidad!: EvaluacionProbatoria;
  posicion_defensiva?: string;
}

export class UpdateEvidenceDto {
  pruebas!: EvidenceItemDto[];
}
EOF

# risks
scaffold_module "risks" "Risks"
mkf "modules/risks/risks.controller.ts" <<'EOF'
import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { RisksService } from './risks.service';
import { UpdateRisksDto } from './dto/update-risks.dto';

/**
 * GET /api/v1/cases/:id/risks
 * PUT /api/v1/cases/:id/risks → reemplaza el conjunto completo
 * Riesgos críticos (prioridad=critica) deben tener estrategia_mitigacion (MODELO_DATOS_v3).
 */
@Controller('api/v1/cases/:caseId/risks')
export class RisksController {
  constructor(private readonly service: RisksService) {}

  @Get()
  findAll(@Param('caseId') _caseId: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  replace(@Param('caseId') _caseId: string, @Body() _dto: UpdateFactsDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF
mkf "modules/risks/dto/update-risks.dto.ts" <<'EOF'
import { EstadoMitigacion, Impacto, Prioridad, Probabilidad } from '../../../types/enums';

export class RiskItemDto {
  descripcion!: string;
  probabilidad!: Probabilidad;
  impacto!: Impacto;
  prioridad!: Prioridad;
  estrategia_mitigacion?: string;
  estado_mitigacion!: EstadoMitigacion;
  plazo_accion?: string;
  responsable_id?: string;
}

export class UpdateRisksDto {
  riesgos!: RiskItemDto[];
}
EOF

# strategy
scaffold_module "strategy" "Strategy"
mkf "modules/strategy/strategy.module.ts" <<'EOF'
import { Module } from '@nestjs/common';
import { StrategyController } from './strategy.controller';
import { TimelineController } from './timeline.controller';
import { StrategyService } from './strategy.service';
import { StrategyRepository } from './strategy.repository';

@Module({
  controllers: [StrategyController, TimelineController],
  providers: [StrategyService, StrategyRepository],
  exports: [StrategyService],
})
export class StrategyModule {}
EOF

mkf "modules/strategy/strategy.controller.ts" <<'EOF'
import { Body, Controller, Delete, Get, Param, Post, Put } from '@nestjs/common';
import { StrategyService } from './strategy.service';
import { CreateProceedingDto, UpdateStrategyDto } from './dto/update-strategy.dto';

/**
 * GET  /api/v1/cases/:id/strategy
 * PUT  /api/v1/cases/:id/strategy
 * Campos: linea_principal (obligatorio para pendiente_revision),
 * fundamento_juridico, fundamento_probatorio, linea_subsidiaria,
 * posicion_allanamiento, posicion_preacuerdo, posicion_juicio.
 *
 * GET    /api/v1/cases/:id/proceedings
 * POST   /api/v1/cases/:id/proceedings
 * PUT    /api/v1/cases/:id/proceedings/:proc_id
 * DELETE /api/v1/cases/:id/proceedings/:proc_id
 */
@Controller('api/v1/cases/:caseId')
export class StrategyController {
  constructor(private readonly service: StrategyService) {}

  @Get('strategy')
  getStrategy(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put('strategy')
  updateStrategy(@Param('caseId') _id: string, @Body() _dto: UpdateStrategyDto): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Get('proceedings')
  getProceedings(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Post('proceedings')
  createProceeding(@Param('caseId') _id: string, @Body() _dto: CreateProceedingDto): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put('proceedings/:procId')
  updateProceeding(
    @Param('caseId') _caseId: string,
    @Param('procId') _procId: string,
    @Body() _dto: CreateProceedingDto,
  ): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Delete('proceedings/:procId')
  deleteProceeding(
    @Param('caseId') _caseId: string,
    @Param('procId') _procId: string,
  ): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF
mkf "modules/strategy/dto/update-strategy.dto.ts" <<'EOF'
/** linea_principal obligatorio para transición a pendiente_revision (R02, CONTRATO_API_v4). */
export class UpdateStrategyDto {
  linea_principal?: string;
  fundamento_juridico?: string;
  fundamento_probatorio?: string;
  linea_subsidiaria?: string;
  posicion_allanamiento?: string;
  posicion_preacuerdo?: string;
  posicion_juicio?: string;
}

export class CreateProceedingDto {
  descripcion!: string;
  fecha?: string;
  responsable_id?: string;
  responsable_externo?: string;
  completada?: boolean;
}
EOF

# client-briefing
scaffold_module "client-briefing" "ClientBriefing"
mkf "modules/client-briefing/client-briefing.controller.ts" <<'EOF'
import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { ClientBriefingService } from './client-briefing.service';
import { UpdateClientBriefingDto } from './dto/update-client-briefing.dto';

/**
 * GET /api/v1/cases/:id/client-briefing
 * PUT /api/v1/cases/:id/client-briefing
 * situacion_libertad del procesado vive en clients, NO aquí (MODELO_DATOS_v3).
 * Campos: delito_explicado, riesgos_informados, panorama_probatorio,
 * beneficios_informados, opciones_explicadas, recomendacion,
 * decision_cliente, fecha_explicacion.
 */
@Controller('api/v1/cases/:caseId/client-briefing')
export class ClientBriefingController {
  constructor(private readonly service: ClientBriefingService) {}

  @Get()
  get(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  update(@Param('caseId') _id: string, @Body() _dto: UpdateClientBriefingDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF
mkf "modules/client-briefing/dto/update-client-briefing.dto.ts" <<'EOF'
/** MODELO_DATOS_v3 — tabla explicacion_cliente. */
export class UpdateClientBriefingDto {
  delito_explicado?: string;
  riesgos_informados?: string;
  panorama_probatorio?: string;
  beneficios_informados?: string;
  opciones_explicadas?: string;
  recomendacion?: string;
  decision_cliente?: string;
  fecha_explicacion?: string;
}
EOF

# checklist
scaffold_module "checklist" "Checklist"
mkf "modules/checklist/checklist.controller.ts" <<'EOF'
import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { ChecklistService } from './checklist.service';
import { UpdateChecklistDto } from './dto/update-checklist-item.dto';

/**
 * GET /api/v1/cases/:id/checklist  → bloques con ítems y estado
 * PUT /api/v1/cases/:id/checklist  → marca/desmarca ítems
 *
 * completado del bloque es calculado por backend — no escribible (R02).
 * critico vive en el bloque, NO en el ítem (MODELO_DATOS_v3).
 * Se genera automáticamente al activar el caso (borrador→en_analisis) (R08).
 */
@Controller('api/v1/cases/:caseId/checklist')
export class ChecklistController {
  constructor(private readonly service: ChecklistService) {}

  @Get()
  get(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  updateItems(@Param('caseId') _id: string, @Body() _dto: UpdateChecklistDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF
mkf "modules/checklist/dto/update-checklist-item.dto.ts" <<'EOF'
/** Actualización de estado de uno o varios ítems del checklist. */
export class ChecklistItemUpdateDto {
  id!: string;
  marcado!: boolean;
}

export class UpdateChecklistDto {
  items!: ChecklistItemUpdateDto[];
}
EOF

# conclusion
scaffold_module "conclusion" "Conclusion"
mkf "modules/conclusion/conclusion.controller.ts" <<'EOF'
import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { ConclusionService } from './conclusion.service';
import { UpdateConclusionDto } from './dto/update-conclusion.dto';

/**
 * GET /api/v1/cases/:id/conclusion
 * PUT /api/v1/cases/:id/conclusion  → actualiza campos; todos opcionales por separado
 *
 * Cinco bloques obligatorios para generar informe conclusion_operativa (R03).
 * recomendacion no puede ser nulo para aprobado_supervisor→listo_para_cliente.
 * Estructura completa: MODELO_DATOS_v3 — tabla conclusion_operativa.
 */
@Controller('api/v1/cases/:caseId/conclusion')
export class ConclusionController {
  constructor(private readonly service: ConclusionService) {}

  @Get()
  get(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Put()
  update(@Param('caseId') _id: string, @Body() _dto: UpdateClientBriefingDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF
mkf "modules/conclusion/dto/update-conclusion.dto.ts" <<'EOF'
/**
 * Cinco bloques de conclusion_operativa (MODELO_DATOS_v3).
 * Todos opcionales — PUT actualiza solo los enviados.
 */
export class UpdateConclusionDto {
  // Bloque 1 — Síntesis jurídica
  hechos_sintesis?: string;
  cargo_imputado?: string;
  evaluacion_dogmatica?: string;
  fisuras_fortalezas?: string;
  // Bloque 2 — Panorama procesal
  fortalezas_acusacion?: string;
  debilidades_acusacion?: string;
  prueba_defensa?: string;
  etapa_texto?: string;
  oportunidades?: string;
  // Bloque 3 — Dosimetría y beneficios
  rangos_pena?: string;
  beneficios?: string;
  restricciones_subrogados?: string;
  riesgos_prioritarios?: string;
  // Bloque 4 — Opciones
  opcion_a?: string; consecuencias_a?: string;
  opcion_b?: string; consecuencias_b?: string;
  opcion_c?: string; consecuencias_c?: string;
  // Bloque 5 — Recomendación (obligatorio para listo_para_cliente)
  recomendacion?: string;
  fundamento_recomendacion?: string;
  condicion_vigencia?: string;
  // Adicional
  observaciones?: string;
}
EOF

# review
scaffold_module "review" "Review"
mkf "modules/review/review.controller.ts" <<'EOF'
import { Controller, Get, Post, Param, Body } from '@nestjs/common';
import { ReviewService } from './review.service';
import { CreateReviewDto } from './dto/create-review.dto';

/**
 * GET  /api/v1/cases/:id/review  → historial de revisiones (vigente destacado)
 * POST /api/v1/cases/:id/review  → registra revisión formal
 * GET  /api/v1/cases/:id/review/feedback → observaciones filtradas para estudiante
 *
 * Acceso GET completo: solo Supervisor y Administrador (R04).
 * observaciones obligatorias en aprobado y devuelto.
 * Solo un registro vigente = true por caso (partial unique index).
 */
@Controller('api/v1/cases/:caseId/review')
export class ReviewController {
  constructor(private readonly service: ReviewService) {}

  @Get()
  findAll(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Post()
  create(@Param('caseId') _id: string, @Body() _dto: CreateReviewDto): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Get('feedback')
  getFeedback(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF
mkf "modules/review/dto/create-review.dto.ts" <<'EOF'
import { ResultadoRevision } from '../../../types/enums';

/**
 * Registro formal de revisión del supervisor.
 * observaciones no puede estar vacío (R04, MODELO_DATOS_v3 — revision_supervisor).
 */
export class CreateReviewDto {
  resultado!: ResultadoRevision;
  observaciones!: string;
  fecha_revision?: string;
}
EOF

# timeline (dentro del módulo strategy por proximidad semántica con actuaciones)
mkf "modules/strategy/timeline.controller.ts" <<'EOF'
import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { StrategyService } from './strategy.service';
import { CreateTimelineEntryDto } from './dto/create-timeline-entry.dto';

/**
 * GET  /api/v1/cases/:id/timeline
 * POST /api/v1/cases/:id/timeline
 * linea_tiempo: append-only (MODELO_DATOS_v3 — Principio 2).
 * UNIQUE (caso_id, orden) en BD.
 */
@Controller('api/v1/cases/:caseId/timeline')
export class TimelineController {
  constructor(private readonly service: StrategyService) {}

  @Get()
  findAll(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Post()
  create(@Param('caseId') _id: string, @Body() _dto: CreateTimelineEntryDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF

mkf "modules/strategy/dto/create-timeline-entry.dto.ts" <<'EOF'
/** Entrada append-only de la línea de tiempo del caso. */
export class CreateTimelineEntryDto {
  orden!: number;
  fecha?: string;
  descripcion!: string;
  fuente?: string;
}
EOF

# reports
scaffold_module "reports" "Reports"
mkf "modules/reports/reports.controller.ts" <<'EOF'
import { Controller, Get, Post, Param, Body, Query } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { GenerateReportDto } from './dto/generate-report.dto';

/**
 * GET  /api/v1/cases/:id/reports            → historial de informes generados
 * POST /api/v1/cases/:id/reports            → solicita generación de informe
 * GET  /api/v1/cases/:id/reports/:reportId  → descarga informe
 *
 * Los informes se generan exclusivamente en backend (PI-01).
 * Todo informe queda registrado en informes_generados (PI-02).
 * Idempotencia: mismo tipo+formato en <5 min retorna el existente (PI-04).
 * 409: estado del caso no permite ese informe.
 * 422: faltan datos para generarlo.
 */
@Controller('api/v1/cases/:caseId/reports')
export class ReportsController {
  constructor(private readonly service: ReportsService) {}

  @Get()
  findAll(@Param('caseId') _id: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Post()
  generate(@Param('caseId') _id: string, @Body() _dto: GenerateReportDto): Promise<unknown> {
    throw new Error('not implemented');
  }

  @Get(':reportId')
  download(
    @Param('caseId') _caseId: string,
    @Param('reportId') _reportId: string,
    @Query('format') _format: string,
  ): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF
mkf "modules/reports/dto/generate-report.dto.ts" <<'EOF'
import { FormatoInforme, TipoInforme } from '../../../types/enums';

/** Solicitud de generación de informe (CATALOGO_INFORMES.md). */
export class GenerateReportDto {
  tipo!: TipoInforme;
  formato!: FormatoInforme;
}
EOF

# audit
scaffold_module "audit" "Audit"
mkf "modules/audit/audit.controller.ts" <<'EOF'
import { Controller, Get, Param, Query } from '@nestjs/common';
import { AuditService } from './audit.service';
import { QueryAuditDto } from './dto/query-audit.dto';

/**
 * GET /api/v1/cases/:id/audit  → log de eventos del caso
 * Acceso: solo Supervisor y Administrador (R06).
 * El endpoint expone solo metadatos — NO prompt_enviado ni respuesta_recibida
 * de ai_request_log (ARQUITECTURA_MODULO_IA_v3).
 */
@Controller('api/v1/cases/:caseId/audit')
export class AuditController {
  constructor(private readonly service: AuditService) {}

  @Get()
  findAll(
    @Param('caseId') _caseId: string,
    @Query() _query: QueryAuditDto,
  ): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF
mkf "modules/audit/dto/query-audit.dto.ts" <<'EOF'
/**
 * Filtros del log de auditoría.
 * tipo: transicion_estado | ia_query | revision_supervisor | informe_generado
 * (valores del modelo, no los stale del contrato anterior).
 */
export class QueryAuditDto {
  tipo?: string;
  page?: number;
  per_page?: number;
}
EOF

# =============================================================================
# MÓDULO: ai
# =============================================================================
echo ""
echo "── Módulo ai (subestructura especial) ───────────────────"

mkf "modules/ai/ai.module.ts" <<'EOF'
import { Module } from '@nestjs/common';
import { AnthropicAdapter } from '../../infrastructure/ai/providers/anthropic.adapter';
import { AIController } from './ai.controller';
import { AIService } from './ai.service';
import { AIContextBuilder } from './context-builders/ai-context-builder';
import { BasicInfoContextBuilder } from './context-builders/basic-info.context-builder';
import { FactsContextBuilder } from './context-builders/facts.context-builder';
import { EvidenceContextBuilder } from './context-builders/evidence.context-builder';
import { RisksContextBuilder } from './context-builders/risks.context-builder';
import { StrategyContextBuilder } from './context-builders/strategy.context-builder';
import { ClientBriefingContextBuilder } from './context-builders/client-briefing.context-builder';
import { ChecklistContextBuilder } from './context-builders/checklist.context-builder';
import { ConclusionContextBuilder } from './context-builders/conclusion.context-builder';
import { AIRequestLogRepository } from './logging/ai-request-log.repository';

/**
 * Módulo de IA (ADR-004, R05, R07).
 * IAProviderAdapter y AnthropicAdapter viven en src/infrastructure/ai/providers/.
 * Plantillas en src/modules/ai/prompt-templates/ (archivos .txt versionados).
 * IAContextBuilder resuelve qué repositorios consultar por herramienta.
 */
@Module({
  controllers: [AIController],
  providers: [
    AIService,
    AIRequestLogRepository,
    AIContextBuilder,
    BasicInfoContextBuilder,
    FactsContextBuilder,
    EvidenceContextBuilder,
    RisksContextBuilder,
    StrategyContextBuilder,
    ClientBriefingContextBuilder,
    ChecklistContextBuilder,
    ConclusionContextBuilder,
    AnthropicAdapter,
  ],
  exports: [AIService],
})
export class AIModule {}
EOF

mkf "modules/ai/ai.controller.ts" <<'EOF'
import { Controller, Post, Body } from '@nestjs/common';
import { AIService } from './ai.service';
import { AIQueryDto } from './dto/ai-query.dto';

/**
 * POST /api/v1/ai/query
 *
 * 200: respuesta + tokens_entrada + tokens_salida + modelo_usado
 * 503: proveedor no disponible (caso y herramientas siguen operando)
 * 500: proveedor respondió pero falló el log — no se entrega la respuesta (RI-IA-02)
 * 422: valor de herramienta no es uno de los 8 canónicos
 * No disponible para casos en estado cerrado (R09).
 */
@Controller('api/v1/ai')
export class AIController {
  constructor(private readonly service: AIService) {}

  @Post('query')
  query(@Body() _dto: AIQueryDto): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF

mkf "modules/ai/ai.service.ts" <<'EOF'
import { Injectable } from '@nestjs/common';
import { AnthropicAdapter } from '../../infrastructure/ai/providers/anthropic.adapter';
import { IAContextBuilder } from './context-builders/ai-context-builder';
import { AIRequestLogRepository } from './logging/ai-request-log.repository';

/**
 * Orquesta el flujo completo de una consulta (ARQUITECTURA_MODULO_IA_v3):
 * 1. IAContextBuilder.construir(caso_id, herramienta) → repositorios correctos
 * 2. PromptTemplateRepository.obtener(herramienta) → archivo .txt del repo
 * 3. Construir prompt completo
 * 4. IAOrchestrator.ejecutar(payload) → IAProviderAdapter → proveedor
 * 5. AIRequestLogRepository.insertar(log) ← SIEMPRE, incluso si falló
 * 6. Retornar { contenido, tokens_entrada, tokens_salida, modelo_usado }
 *
 * Si el log falla tras respuesta exitosa → 500, no 503 (RI-IA-02).
 */
@Injectable()
export class AIService {
  constructor(
    private readonly contextBuilder: IAContextBuilder,
    private readonly provider: AnthropicAdapter,
    private readonly logRepository: AIRequestLogRepository,
  ) {}

  consultar(
    _casoId: string,
    _herramienta: string,
    _consulta: string,
    _usuarioId: string,
  ): Promise<unknown> {
    throw new Error('not implemented');
  }
}
EOF

mkf "modules/ai/dto/ai-query.dto.ts" <<'EOF'
import { HerramientaIA } from '../../../types/enums';

/**
 * Body de POST /api/v1/ai/query.
 * herramienta debe ser uno de los 8 valores canónicos (HerramientaIA enum).
 * Cualquier otro valor retorna 422.
 */
export class AIQueryDto {
  caso_id!: string;
  herramienta!: HerramientaIA;
  consulta!: string;
}
EOF

# context-builders
mkf "modules/ai/context-builders/ai-context-builder.ts" <<'EOF'
import { Injectable } from '@nestjs/common';
import { HerramientaIA } from '../../../types/enums';
import { IAContexto } from '../../../types/interfaces';

/**
 * Orquestador de context builders.
 * Resuelve qué builder usar según el valor canónico de herramienta.
 * Cada builder sabe qué repositorios consultar para su herramienta.
 *
 * Mapa de repositorios por herramienta (ARQUITECTURA_MODULO_IA_v3):
 * basic-info     → casos
 * facts          → casos, hechos
 * evidence       → casos, pruebas
 * risks          → casos, riesgos
 * strategy       → casos, estrategia, actuaciones
 * client-briefing→ casos, clientes, explicacion_cliente
 * checklist      → casos, checklist_bloques, checklist_items
 * conclusion     → casos, conclusion_operativa
 */
@Injectable()
export class AIContextBuilder {
  construir(_casoId: string, _herramienta: HerramientaIA): Promise<IAContexto> {
    throw new Error('not implemented');
  }
}
EOF

# 8 builders individuales
for herramienta in basic-info facts evidence risks strategy client-briefing checklist conclusion; do
  pascal=$(echo "$herramienta" | sed -r 's/(^|-)([a-z])/\U\2/g')
  mkf "modules/ai/context-builders/${herramienta}.context-builder.ts" <<EOF
import { Injectable } from '@nestjs/common';
import { IAContexto } from '../../../types/interfaces';

/**
 * Builder de contexto para herramienta: ${herramienta}
 * Consulta los repositorios necesarios y retorna IAContexto tipado.
 * Ver tabla de repositorios en ai-context-builder.ts.
 */
@Injectable()
export class ${pascal}ContextBuilder {
  construir(_casoId: string): Promise<IAContexto> {
    throw new Error('not implemented');
  }
}
EOF
done

# prompt-templates: 8 archivos .txt
for herramienta in basic-info facts evidence risks strategy client-briefing checklist conclusion; do
  mkf "modules/ai/prompt-templates/${herramienta}.txt" <<EOF
# Plantilla de prompt — herramienta: ${herramienta}
# Almacenamiento: archivos versionados en repo (decisión MVP, ARQUITECTURA_MODULO_IA_v3).
# Cambios se auditan por historial de git. El log de IA almacena el prompt completo (RI-IA-03).
#
# INSTRUCCIÓN DE SISTEMA
# Eres un asistente jurídico especializado en defensa penal colombiana.
# Tu función es apoyar el análisis del caso — no tomar decisiones.
# No emitas conclusiones definitivas. Orienta, señala vacíos, sugiere perspectivas.
#
# CONTEXTO MÍNIMO DEL CASO (siempre presente)
# Radicado: {radicado}
# Delito imputado: {delito_imputado}
# Etapa procesal: {etapa_procesal}
# Régimen procesal: {regimen_procesal}
#
# CONTEXTO AMPLIADO — ${herramienta}
# {contexto_ampliado}
#
# CONSULTA DEL RESPONSABLE
# {consulta_usuario}
#
# [completar con instrucciones específicas de la herramienta]
EOF
done

# logging
mkf "modules/ai/logging/ai-request-log.repository.ts" <<'EOF'
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/database/prisma/prisma.service';

/**
 * Repositorio de log de IA — solo INSERT, nunca UPDATE ni DELETE (R05, RI-IA-02).
 * Registra toda llamada al módulo de IA, exitosa o fallida.
 * Si insertar falla después de respuesta exitosa → la operación retorna 500.
 * No puede haber llamadas no registradas.
 *
 * Campos: caso_id, usuario_id, herramienta, proveedor, modelo,
 *         prompt_enviado, respuesta_recibida, tokens_entrada, tokens_salida,
 *         duracion_ms, estado_llamada, error_mensaje.
 *
 * El endpoint GET /audit NO expone prompt_enviado ni respuesta_recibida.
 */
@Injectable()
export class AIRequestLogRepository {
  constructor(private readonly prisma: PrismaService) {}

  insertar(_log: Record<string, unknown>): Promise<void> {
    throw new Error('not implemented');
  }
}
EOF

# =============================================================================
# app.module.ts — registra los 15 módulos
# =============================================================================
echo ""
echo "── AppModule ─────────────────────────────────────────────"

mkf "app.module.ts" <<'EOF'
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { appConfig } from './config/app.config';
import { databaseConfig } from './config/database.config';
import { jwtConfig } from './config/jwt.config';
import { aiConfig } from './config/ai.config';

import { PrismaModule } from './infrastructure/database/prisma/prisma.module';

// Módulos de plataforma
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';

// Módulo agregado raíz
import { CasesModule } from './modules/cases/cases.module';

// Módulo de clientes
import { ClientsModule } from './modules/clients/clients.module';

// Herramientas operativas del caso
import { FactsModule } from './modules/facts/facts.module';
import { EvidenceModule } from './modules/evidence/evidence.module';
import { RisksModule } from './modules/risks/risks.module';
import { StrategyModule } from './modules/strategy/strategy.module';
import { ClientBriefingModule } from './modules/client-briefing/client-briefing.module';
import { ChecklistModule } from './modules/checklist/checklist.module';
import { ConclusionModule } from './modules/conclusion/conclusion.module';

// Flujos formales
import { ReviewModule } from './modules/review/review.module';
import { ReportsModule } from './modules/reports/reports.module';

// Transversales
import { AIModule } from './modules/ai/ai.module';
import { AuditModule } from './modules/audit/audit.module';

/**
 * Módulo raíz de LexPenal backend.
 * 15 módulos registrados según canon src/ (CONTRATO_API_v4, MODELO_DATOS_v3).
 * Stack: NestJS + TypeScript + Prisma + PostgreSQL (ADR-001, ADR-002, ADR-006).
 */
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig, databaseConfig, jwtConfig, aiConfig],
    }),
    PrismaModule,
    // Plataforma
    AuthModule,
    UsersModule,
    // Dominio
    CasesModule,
    ClientsModule,
    // Herramientas
    FactsModule,
    EvidenceModule,
    RisksModule,
    StrategyModule,
    ClientBriefingModule,
    ChecklistModule,
    ConclusionModule,
    // Flujos formales
    ReviewModule,
    ReportsModule,
    // Transversales
    AIModule,
    AuditModule,
  ],
})
export class AppModule {}
EOF

# main.ts
mkf "main.ts" <<'EOF'
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  app.useGlobalFilters(new HttpExceptionFilter());
  const port = process.env.PORT ?? 3001;
  await app.listen(port);
  console.log(`LexPenal backend running on port ${port}`);
}

bootstrap();
EOF

# =============================================================================
# RESUMEN
# =============================================================================
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Estructura canónica generada en: $ROOT"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  Módulos (15):"
echo "    auth · users · cases · clients"
echo "    facts · evidence · risks · strategy"
echo "    client-briefing · checklist · conclusion · review"
echo "    reports · ai · audit"
echo ""
echo "  Infraestructura:"
echo "    database/prisma · ai/providers"
echo ""
echo "  Transversal:"
echo "    common · config · contracts · types"
echo ""
echo "  IA (subestructura):"
echo "    context-builders (8 + orquestador)"
echo "    prompt-templates (8 .txt)"
echo "    logging (AIRequestLogRepository)"
echo ""
echo "  Siguientes pasos:"
echo "    1. npm install (en el proyecto NestJS)"
echo "    2. Generar schema.prisma desde MODELO_DATOS_v3.md"
echo "    3. prisma migrate dev --name init"
echo "    4. Implementar módulos por hito (ROADMAP.md)"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  Resultado:"
echo "    creados:      $created"
echo "    actualizados: $updated"
echo "    sin cambios:  $unchanged"
echo "    omitidos:     $skipped"
echo "    backups:      $backed_up"
if [[ "$backed_up" -gt 0 ]]; then
  echo "    ruta backup:  $BACKUP_DIR"
fi
