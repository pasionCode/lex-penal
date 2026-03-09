/**
 * CasoEstadoService — Servicio de transiciones de estado del caso.
 *
 * Fuentes canónicas:
 * - ADR-003: Máquina de estados del caso
 * - R08: Al activar un caso se genera su estructura base
 * - R09: Un caso cerrado es inmutable
 * - R06: Toda acción crítica es auditable
 *
 * Este servicio es el ÚNICO punto de modificación del campo estado_actual.
 * Ningún otro servicio puede modificar el estado del caso directamente.
 *
 * NOTA DE WIRING (Nest):
 * Este servicio NO debe inyectar ChecklistService directamente para evitar
 * dependencia circular entre módulos cases y checklist. Las verificaciones
 * de checklist se hacen mediante consultas directas a Prisma. Si en el futuro
 * se requiere lógica compleja de ChecklistService, usar forwardRef() o
 * extraer la lógica compartida a un módulo común.
 *
 * FLUJO DE OBSERVACIONES:
 * En transiciones pendiente_revision → devuelto/aprobado_supervisor:
 * - Las observaciones vienen de metadata.observaciones (obligatorias)
 * - Se persisten en revision_supervisor con resultado correspondiente
 * - La revisión anterior (si existe) se marca como vigente = false
 */

import {
  Injectable,
  ConflictException,
  ForbiddenException,
  UnprocessableEntityException,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../../infrastructure/database/prisma/prisma.service';
import { EstadoCaso, PerfilUsuario, TipoEvento, ResultadoAuditoria } from '../../../types/enums';
import {
  TRANSICIONES_VALIDAS,
  PERMISOS_TRANSICION,
  ESTADOS_ESCRITURA_BLOQUEADA,
  BLOQUES_CHECKLIST_U008,
  claveTransicion,
} from './caso-estado.constants';

// ============================================================================
// INTERFACES
// ============================================================================

export interface TransicionMetadata {
  observaciones?: string;
}

export interface ValidacionTransicion {
  valida: boolean;
  motivos: string[];
}

export interface TransicionRechazadaError {
  error: 'TRANSITION_REJECTED';
  estadoActual: EstadoCaso;
  estadoSolicitado: EstadoCaso;
  motivos: string[];
}

export interface EscrituraBloqueadaError {
  error: 'ESCRITURA_BLOQUEADA';
  estadoActual: EstadoCaso;
  mensaje: string;
}

// ============================================================================
// SERVICIO
// ============================================================================

@Injectable()
export class CasoEstadoService {
  constructor(private readonly prisma: PrismaService) {}

  // --------------------------------------------------------------------------
  // MÉTODO PRINCIPAL: transicionar()
  // --------------------------------------------------------------------------

  /**
   * Ejecuta una transición de estado.
   * Verifica permisos, guardas, ejecuta acciones asociadas y registra auditoría.
   *
   * @throws NotFoundException (404) si el caso no existe
   * @throws ForbiddenException (403) si el perfil no tiene permiso
   * @throws ConflictException (409) si la transición no es válida desde el estado actual
   * @throws UnprocessableEntityException (422) si las guardas no se cumplen
   */
  async transicionar(
    casoId: string,
    estadoDestino: EstadoCaso,
    usuarioId: string,
    perfilUsuario: PerfilUsuario,
    metadata?: TransicionMetadata,
  ) {
    // 1. Obtener caso con estado actual
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: {
        id: true,
        estado_actual: true,
        radicado: true,
        cliente_id: true,
        delito_imputado: true,
        etapa_procesal: true,
      },
    });

    if (!caso) {
      throw new NotFoundException(`Caso ${casoId} no encontrado`);
    }

    const estadoActual = caso.estado_actual as EstadoCaso;

    // 2. Verificar que la transición es válida (matriz)
    const transicionesValidas = TRANSICIONES_VALIDAS[estadoActual] || [];
    if (!transicionesValidas.includes(estadoDestino)) {
      throw new ConflictException({
        error: 'TRANSICION_INVALIDA',
        estadoActual,
        estadoSolicitado: estadoDestino,
        transicionesValidas,
        mensaje: `No se puede transicionar de "${estadoActual}" a "${estadoDestino}"`,
      });
    }

    // 3. Verificar permiso del perfil del usuario
    const clave = claveTransicion(estadoActual, estadoDestino);
    const perfilesPermitidos = PERMISOS_TRANSICION[clave] || [];
    if (!perfilesPermitidos.includes(perfilUsuario)) {
      throw new ForbiddenException({
        error: 'PERMISO_DENEGADO',
        transicion: clave,
        perfilUsuario,
        perfilesPermitidos,
        mensaje: `El perfil "${perfilUsuario}" no puede ejecutar la transición "${clave}"`,
      });
    }

    // 4. Ejecutar verificación de guardas específicas
    const validacion = await this.verificarGuardas(
      casoId,
      estadoActual,
      estadoDestino,
      metadata,
    );
    if (!validacion.valida) {
      throw new UnprocessableEntityException({
        error: 'TRANSITION_REJECTED',
        estadoActual,
        estadoSolicitado: estadoDestino,
        motivos: validacion.motivos,
      } as TransicionRechazadaError);
    }

    // 5-7. Ejecutar transición en transacción
    const casoActualizado = await this.prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      // 5a. Si es borrador→en_analisis: generar estructura base (R08)
      if (
        estadoActual === EstadoCaso.BORRADOR &&
        estadoDestino === EstadoCaso.EN_ANALISIS
      ) {
        await this.generarEstructuraBase(tx, casoId, usuarioId);
      }

      // 5b. Si es transición de supervisor: persistir revisión
      if (
        (estadoActual === EstadoCaso.PENDIENTE_REVISION &&
          estadoDestino === EstadoCaso.DEVUELTO) ||
        (estadoActual === EstadoCaso.PENDIENTE_REVISION &&
          estadoDestino === EstadoCaso.APROBADO_SUPERVISOR)
      ) {
        await this.persistirRevisionSupervisor(
          tx,
          casoId,
          usuarioId,
          metadata?.observaciones || '',
          estadoDestino === EstadoCaso.APROBADO_SUPERVISOR ? 'aprobado' : 'devuelto',
        );
      }

      // 6. Actualizar caso
      const updated = await tx.caso.update({
        where: { id: casoId },
        data: {
          estado_anterior: estadoActual,
          estado_actual: estadoDestino,
          fecha_cambio_estado: new Date(),
          usuario_cambio_estado: usuarioId,
          actualizado_por: usuarioId,
        },
      });

      // 7. Registrar evento de auditoría
      await tx.eventoAuditoria.create({
        data: {
          caso_id: casoId,
          usuario_id: usuarioId,
          tipo_evento: TipoEvento.TRANSICION_ESTADO,
          estado_origen: estadoActual,
          estado_destino: estadoDestino,
          resultado: ResultadoAuditoria.EXITOSO,
          metadata: metadata ? JSON.parse(JSON.stringify(metadata)) : undefined,
        },
      });

      return updated;
    });

    return casoActualizado;
  }

  // --------------------------------------------------------------------------
  // VERIFICACIÓN DE ESCRITURA (R08, R09)
  // --------------------------------------------------------------------------

  /**
   * Verifica si un caso permite operaciones de escritura.
   * Usado por otros servicios antes de modificar herramientas.
   *
   * Comportamiento:
   * - Si el caso no existe: lanza NotFoundException (404)
   * - Si el estado bloquea escritura: lanza ConflictException (409)
   * - Si permite escritura: retorna void (sin excepción)
   *
   * @throws NotFoundException (404) si el caso no existe
   * @throws ConflictException (409) si el estado no permite escritura
   */
  async verificarEscritura(casoId: string): Promise<void> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: { estado_actual: true },
    });

    if (!caso) {
      throw new NotFoundException({
        error: 'CASO_NO_ENCONTRADO',
        casoId,
        mensaje: `Caso ${casoId} no encontrado`,
      });
    }

    const estadoActual = caso.estado_actual as EstadoCaso;

    if (ESTADOS_ESCRITURA_BLOQUEADA.includes(estadoActual)) {
      throw new ConflictException({
        error: 'ESCRITURA_BLOQUEADA',
        estadoActual,
        mensaje: `El caso en estado "${estadoActual}" no permite modificaciones.`,
      } as EscrituraBloqueadaError);
    }
  }

  // --------------------------------------------------------------------------
  // TRANSICIONES DISPONIBLES
  // --------------------------------------------------------------------------

  /**
   * Retorna las transiciones disponibles para un caso y perfil dados.
   * Usado por el frontend para renderizar acciones disponibles.
   */
  async obtenerTransicionesDisponibles(
    casoId: string,
    perfilUsuario: PerfilUsuario,
  ): Promise<EstadoCaso[]> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: { estado_actual: true },
    });

    if (!caso) {
      throw new NotFoundException(`Caso ${casoId} no encontrado`);
    }

    const estadoActual = caso.estado_actual as EstadoCaso;
    const transicionesValidas = TRANSICIONES_VALIDAS[estadoActual] || [];

    // Filtrar por permisos del perfil
    return transicionesValidas.filter((destino) => {
      const clave = claveTransicion(estadoActual, destino);
      const perfilesPermitidos = PERMISOS_TRANSICION[clave] || [];
      return perfilesPermitidos.includes(perfilUsuario);
    });
  }

  // --------------------------------------------------------------------------
  // VALIDACIÓN DE TRANSICIÓN (sin ejecutar)
  // --------------------------------------------------------------------------

  /**
   * Valida las guardas de una transición sin ejecutarla.
   * Retorna lista de motivos de rechazo si alguna guarda falla.
   */
  async validarTransicion(
    casoId: string,
    estadoDestino: EstadoCaso,
    metadata?: TransicionMetadata,
  ): Promise<ValidacionTransicion> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: { estado_actual: true },
    });

    if (!caso) {
      throw new NotFoundException(`Caso ${casoId} no encontrado`);
    }

    const estadoActual = caso.estado_actual as EstadoCaso;
    return this.verificarGuardas(casoId, estadoActual, estadoDestino, metadata);
  }

  // --------------------------------------------------------------------------
  // GUARDAS POR TRANSICIÓN
  // --------------------------------------------------------------------------

  /**
   * Verifica las guardas específicas de una transición.
   * Fuente: ADR-003 — Reglas de guardia por transición.
   */
  private async verificarGuardas(
    casoId: string,
    estadoOrigen: EstadoCaso,
    estadoDestino: EstadoCaso,
    metadata?: TransicionMetadata,
  ): Promise<ValidacionTransicion> {
    const motivos: string[] = [];

    switch (`${estadoOrigen}→${estadoDestino}`) {
      case 'borrador→en_analisis':
        await this.verificarGuardaBorradorAEnAnalisis(casoId, motivos);
        break;

      case 'en_analisis→pendiente_revision':
        await this.verificarGuardaEnAnalisisAPendienteRevision(casoId, motivos);
        break;

      case 'pendiente_revision→devuelto':
        this.verificarGuardaObservacionesRequeridas(metadata, motivos);
        break;

      case 'pendiente_revision→aprobado_supervisor':
        await this.verificarGuardaAprobacionSupervisor(casoId, metadata, motivos);
        break;

      case 'devuelto→en_analisis':
        await this.verificarGuardaDevueltoAEnAnalisis(casoId, motivos);
        break;

      case 'aprobado_supervisor→listo_para_cliente':
        await this.verificarGuardaListoParaCliente(casoId, motivos);
        break;

      case 'listo_para_cliente→cerrado':
        await this.verificarGuardaCierre(casoId, motivos);
        break;
    }

    return {
      valida: motivos.length === 0,
      motivos,
    };
  }

  // --------------------------------------------------------------------------
  // GUARDAS INDIVIDUALES
  // --------------------------------------------------------------------------

  /**
   * Guarda: borrador → en_analisis
   * - Ficha básica completa (radicado, cliente_id, delito_imputado, etapa_procesal)
   */
  private async verificarGuardaBorradorAEnAnalisis(
    casoId: string,
    motivos: string[],
  ): Promise<void> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: {
        radicado: true,
        cliente_id: true,
        delito_imputado: true,
        etapa_procesal: true,
      },
    });

    if (!caso?.radicado) {
      motivos.push('El radicado es obligatorio.');
    }
    if (!caso?.cliente_id) {
      motivos.push('El procesado (cliente) es obligatorio.');
    }
    if (!caso?.delito_imputado) {
      motivos.push('El delito imputado es obligatorio.');
    }
    if (!caso?.etapa_procesal) {
      motivos.push('La etapa procesal es obligatoria.');
    }
  }

  /**
   * Guarda: en_analisis → pendiente_revision
   * - Checklist sin bloques críticos incompletos (R02)
   * - Estrategia con línea defensiva
   * - Al menos un hecho registrado
   */
  private async verificarGuardaEnAnalisisAPendienteRevision(
    casoId: string,
    motivos: string[],
  ): Promise<void> {
    // Verificar checklist
    const bloquesCriticosIncompletos = await this.prisma.checklistBloque.count({
      where: {
        caso_id: casoId,
        critico: true,
        completado: false,
      },
    });
    if (bloquesCriticosIncompletos > 0) {
      motivos.push(
        `El checklist tiene ${bloquesCriticosIncompletos} bloque(s) crítico(s) incompleto(s).`,
      );
    }

    // Verificar estrategia
    const estrategia = await this.prisma.estrategia.findUnique({
      where: { caso_id: casoId },
      select: { linea_principal: true },
    });
    if (!estrategia?.linea_principal) {
      motivos.push('La estrategia debe tener al menos una línea defensiva principal.');
    }

    // Verificar hechos
    const cantidadHechos = await this.prisma.hecho.count({
      where: { caso_id: casoId },
    });
    if (cantidadHechos === 0) {
      motivos.push('Debe existir al menos un hecho registrado.');
    }
  }

  /**
   * Guarda: observaciones requeridas (devuelto, aprobado_supervisor)
   */
  private verificarGuardaObservacionesRequeridas(
    metadata: TransicionMetadata | undefined,
    motivos: string[],
  ): void {
    if (!metadata?.observaciones?.trim()) {
      motivos.push('Las observaciones del supervisor son obligatorias.');
    }
  }

  /**
   * Guarda: pendiente_revision → aprobado_supervisor
   * - Observaciones no vacías (se persisten como revisión durante la transición)
   *
   * Nota: La revisión del supervisor se crea EN el momento de la transición,
   * no antes. Por eso solo verificamos que vengan observaciones.
   */
  private async verificarGuardaAprobacionSupervisor(
    casoId: string,
    metadata: TransicionMetadata | undefined,
    motivos: string[],
  ): Promise<void> {
    // Verificar observaciones (obligatorias para crear la revisión)
    this.verificarGuardaObservacionesRequeridas(metadata, motivos);
  }

  /**
   * Guarda: devuelto → en_analisis
   * - Al menos una revisión registrada (la devolución creó una)
   *
   * Nota: Si el caso está en estado devuelto, necesariamente existe
   * al menos una revisión (la que causó la devolución).
   * Esta guarda es más una verificación de integridad que un bloqueo real.
   */
  private async verificarGuardaDevueltoAEnAnalisis(
    casoId: string,
    motivos: string[],
  ): Promise<void> {
    const cantidadRevisiones = await this.prisma.revisionSupervisor.count({
      where: { caso_id: casoId },
    });
    if (cantidadRevisiones === 0) {
      // Esto indicaría un problema de integridad en los datos
      motivos.push(
        'Error de integridad: caso en estado devuelto sin revisión registrada.',
      );
    }
  }

  /**
   * Guarda: aprobado_supervisor → listo_para_cliente
   * - Conclusión operativa completa (5 bloques)
   * - Recomendación no vacía
   * - Checklist sin bloques críticos incompletos
   */
  private async verificarGuardaListoParaCliente(
    casoId: string,
    motivos: string[],
  ): Promise<void> {
    // Verificar conclusión
    const conclusion = await this.prisma.conclusionOperativa.findUnique({
      where: { caso_id: casoId },
      select: {
        hechos_sintesis: true,
        fortalezas_acusacion: true,
        rangos_pena: true,
        opcion_a: true,
        recomendacion: true,
      },
    });

    if (!conclusion) {
      motivos.push('La conclusión operativa no existe.');
    } else {
      // Verificar 5 bloques principales
      if (!conclusion.hechos_sintesis) {
        motivos.push('Bloque 1 (síntesis jurídica) de la conclusión está incompleto.');
      }
      if (!conclusion.fortalezas_acusacion) {
        motivos.push('Bloque 2 (panorama procesal) de la conclusión está incompleto.');
      }
      if (!conclusion.rangos_pena) {
        motivos.push('Bloque 3 (dosimetría) de la conclusión está incompleto.');
      }
      if (!conclusion.opcion_a) {
        motivos.push('Bloque 4 (opciones) de la conclusión está incompleto.');
      }
      if (!conclusion.recomendacion) {
        motivos.push('La recomendación estratégica es obligatoria.');
      }
    }

    // Verificar checklist nuevamente
    const bloquesCriticosIncompletos = await this.prisma.checklistBloque.count({
      where: {
        caso_id: casoId,
        critico: true,
        completado: false,
      },
    });
    if (bloquesCriticosIncompletos > 0) {
      motivos.push(
        `El checklist tiene ${bloquesCriticosIncompletos} bloque(s) crítico(s) incompleto(s).`,
      );
    }
  }

  /**
   * Guarda: listo_para_cliente → cerrado
   * - Decisión del cliente documentada
   */
  private async verificarGuardaCierre(
    casoId: string,
    motivos: string[],
  ): Promise<void> {
    const explicacion = await this.prisma.explicacionCliente.findUnique({
      where: { caso_id: casoId },
      select: { decision_cliente: true },
    });

    if (!explicacion?.decision_cliente?.trim()) {
      motivos.push(
        'La decisión del cliente debe estar documentada en la explicación al cliente.',
      );
    }
  }

  // --------------------------------------------------------------------------
  // PERSISTENCIA DE REVISIÓN DEL SUPERVISOR
  // --------------------------------------------------------------------------

  /**
   * Persiste la revisión del supervisor al ejecutar transiciones de aprobación/devolución.
   *
   * Flujo:
   * 1. Marca revisiones anteriores como vigente = false
   * 2. Calcula siguiente version_revision
   * 3. Crea nueva revisión con vigente = true
   *
   * @param tx - Transacción de Prisma
   * @param casoId - ID del caso
   * @param supervisorId - ID del usuario supervisor
   * @param observaciones - Observaciones obligatorias
   * @param resultado - 'aprobado' | 'devuelto'
   */
  private async persistirRevisionSupervisor(
    tx: Prisma.TransactionClient,
    casoId: string,
    supervisorId: string,
    observaciones: string,
    resultado: 'aprobado' | 'devuelto',
  ): Promise<void> {
    // 1. Marcar revisiones anteriores como no vigentes
    await tx.revisionSupervisor.updateMany({
      where: {
        caso_id: casoId,
        vigente: true,
      },
      data: {
        vigente: false,
      },
    });

    // 2. Obtener siguiente versión
    const ultimaRevision = await tx.revisionSupervisor.findFirst({
      where: { caso_id: casoId },
      orderBy: { version_revision: 'desc' },
      select: { version_revision: true },
    });
    const siguienteVersion = (ultimaRevision?.version_revision || 0) + 1;

    // 3. Crear nueva revisión
    await tx.revisionSupervisor.create({
      data: {
        caso_id: casoId,
        supervisor_id: supervisorId,
        version_revision: siguienteVersion,
        vigente: true,
        observaciones,
        fecha_revision: new Date(),
        resultado,
        creado_por: supervisorId,
      },
    });
  }

  // --------------------------------------------------------------------------
  // GENERACIÓN DE ESTRUCTURA BASE (R08)
  // --------------------------------------------------------------------------

  /**
   * Genera la estructura base de herramientas al activar un caso.
   * Se ejecuta en transición borrador → en_analisis.
   *
   * IDEMPOTENCIA: Si por error se intenta ejecutar dos veces, no duplica
   * registros. Verifica existencia antes de crear.
   *
   * Crea:
   * - checklist_bloques (12 bloques del U008)
   * - checklist_items (ítems por bloque) — TODO: definir ítems específicos
   * - estrategia (registro vacío)
   * - explicacion_cliente (registro vacío)
   * - conclusion_operativa (registro vacío)
   */
  private async generarEstructuraBase(
    tx: Prisma.TransactionClient,
    casoId: string,
    usuarioId: string,
  ): Promise<void> {
    // 1. Crear checklist_bloques (solo si no existen)
    const bloquesExistentes = await tx.checklistBloque.count({
      where: { caso_id: casoId },
    });

    if (bloquesExistentes === 0) {
      for (const bloque of BLOQUES_CHECKLIST_U008) {
        await tx.checklistBloque.create({
          data: {
            caso_id: casoId,
            codigo_bloque: bloque.codigo,
            nombre_bloque: bloque.nombre,
            critico: bloque.critico,
            completado: false,
          },
        });
      }
    }

    // TODO: 2. Crear checklist_items por bloque (con verificación de existencia)
    // Requiere definir ítems específicos del U008 por bloque

    // 3. Crear estrategia vacía (solo si no existe)
    const estrategiaExiste = await tx.estrategia.findUnique({
      where: { caso_id: casoId },
    });
    if (!estrategiaExiste) {
      await tx.estrategia.create({
        data: {
          caso_id: casoId,
          creado_por: usuarioId,
        },
      });
    }

    // 4. Crear explicacion_cliente vacía (solo si no existe)
    const explicacionExiste = await tx.explicacionCliente.findUnique({
      where: { caso_id: casoId },
    });
    if (!explicacionExiste) {
      await tx.explicacionCliente.create({
        data: {
          caso_id: casoId,
          creado_por: usuarioId,
        },
      });
    }

    // 5. Crear conclusion_operativa vacía (solo si no existe)
    const conclusionExiste = await tx.conclusionOperativa.findUnique({
      where: { caso_id: casoId },
    });
    if (!conclusionExiste) {
      await tx.conclusionOperativa.create({
        data: {
          caso_id: casoId,
          creado_por: usuarioId,
        },
      });
    }
  }
}
