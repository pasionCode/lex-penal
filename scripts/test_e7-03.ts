/**
 * ==============================================================================
 * E7-03 RUNTIME — VERIFICACIÓN HARDENING (caso_id, version_revision)
 * ==============================================================================
 * Proyecto: LEX_PENAL
 * Fase: E7
 * Unidad: E7-03
 * Fecha: 2026-03-30
 * ==============================================================================
 * 
 * Este script verifica que el hardening existente funciona correctamente:
 * - Constraint @@unique([caso_id, version_revision])
 * - Transacción atómica en createWithAudit()
 * 
 * Ejecutar: npx ts-node scripts/test_e7-03.ts
 * ==============================================================================
 */

import { PrismaClient, ResultadoRevision } from '@prisma/client';

const prisma = new PrismaClient();

// Constantes de prueba
const TEST_CASE_ID = 'c9f0c313-1042-42f7-8371-faa89fd84f42';
const ADMIN_USER_ID = '71e47a55-8803-4842-bf3c-c573bf2cc709';

interface TestResult {
  name: string;
  passed: boolean;
  detail: string;
}

const results: TestResult[] = [];

function log(msg: string) {
  console.log(msg);
}

function logPass(name: string, detail: string) {
  console.log(`\x1b[32m[PASS]\x1b[0m ${name}`);
  results.push({ name, passed: true, detail });
}

function logFail(name: string, detail: string) {
  console.log(`\x1b[31m[FAIL]\x1b[0m ${name}`);
  console.log(`       ${detail}`);
  results.push({ name, passed: false, detail });
}

/**
 * PRUEBA 1 — Unicidad real
 * Confirmar que el constraint rechaza duplicados a nivel de DB.
 */
async function prueba1_unicidadReal(): Promise<void> {
  log('\n=== PRUEBA 1: UNICIDAD REAL ===\n');

  // 1.1 Obtener última versión existente
  const lastRevision = await prisma.revisionSupervisor.findFirst({
    where: { caso_id: TEST_CASE_ID },
    orderBy: { version_revision: 'desc' },
    select: { version_revision: true, id: true },
  });

  const versionExistente = lastRevision?.version_revision ?? 0;
  log(`Última versión existente: ${versionExistente}`);

  if (versionExistente === 0) {
    // Crear una revisión base para tener algo que duplicar
    log('No hay revisiones previas. Creando revisión base...');
    
    await prisma.revisionSupervisor.create({
      data: {
        caso_id: TEST_CASE_ID,
        supervisor_id: ADMIN_USER_ID,
        version_revision: 1,
        vigente: true,
        observaciones: 'Revisión base para prueba E7-03',
        resultado: ResultadoRevision.aprobado,
        creado_por: ADMIN_USER_ID,
      },
    });
    log('Revisión base creada con version_revision=1');
  }

  // 1.2 Intentar insertar duplicado directo (bypass del servicio)
  const versionADuplicar = versionExistente > 0 ? versionExistente : 1;
  log(`Intentando duplicar version_revision=${versionADuplicar}...`);

  try {
    await prisma.revisionSupervisor.create({
      data: {
        caso_id: TEST_CASE_ID,
        supervisor_id: ADMIN_USER_ID,
        version_revision: versionADuplicar, // DUPLICADO INTENCIONAL
        vigente: false,
        observaciones: 'DUPLICADO INTENCIONAL - DEBE FALLAR',
        resultado: ResultadoRevision.devuelto,
        creado_por: ADMIN_USER_ID,
      },
    });

    // Si llegamos aquí, el constraint NO funcionó
    logFail('Prueba 1.1 - Constraint único', 
      `INSERT duplicado fue aceptado. El constraint NO está funcionando.`);

  } catch (error: any) {
    // Verificar que es error de unique constraint
    if (error.code === 'P2002') {
      logPass('Prueba 1.1 - Constraint único', 
        `INSERT duplicado rechazado correctamente (P2002: Unique constraint failed)`);
    } else {
      logFail('Prueba 1.1 - Constraint único', 
        `Error inesperado: ${error.code} - ${error.message}`);
    }
  }

  // 1.3 Verificar que no quedó basura
  const countAfter = await prisma.revisionSupervisor.count({
    where: { 
      caso_id: TEST_CASE_ID,
      version_revision: versionADuplicar,
    },
  });

  if (countAfter === 1) {
    logPass('Prueba 1.2 - Sin basura persistida', 
      `Solo existe 1 registro con version_revision=${versionADuplicar}`);
  } else {
    logFail('Prueba 1.2 - Sin basura persistida', 
      `Existen ${countAfter} registros con version_revision=${versionADuplicar}`);
  }
}

/**
 * PRUEBA 2 — Consistencia del flujo
 * Confirmar que creaciones secuenciales incrementan correctamente.
 */
async function prueba2_consistenciaFlujo(): Promise<void> {
  log('\n=== PRUEBA 2: CONSISTENCIA DEL FLUJO ===\n');

  // 2.1 Obtener estado inicial
  const antes = await prisma.revisionSupervisor.findMany({
    where: { caso_id: TEST_CASE_ID },
    orderBy: { version_revision: 'asc' },
    select: { version_revision: true, vigente: true },
  });

  const versionesAntes = antes.map(r => r.version_revision);
  const maxAntes = Math.max(...versionesAntes, 0);
  log(`Versiones antes: [${versionesAntes.join(', ')}]`);
  log(`Máxima versión: ${maxAntes}`);

  // 2.2 Simular flujo de creación (como lo hace createWithAudit)
  log('Ejecutando creación atómica simulada...');

  const nuevaRevision = await prisma.$transaction(async (tx) => {
    // Marcar anteriores como no vigentes
    await tx.revisionSupervisor.updateMany({
      where: { caso_id: TEST_CASE_ID, vigente: true },
      data: { vigente: false },
    });

    // Calcular siguiente versión
    const last = await tx.revisionSupervisor.findFirst({
      where: { caso_id: TEST_CASE_ID },
      orderBy: { version_revision: 'desc' },
      select: { version_revision: true },
    });
    const nextVersion = (last?.version_revision ?? 0) + 1;

    // Crear revisión
    return tx.revisionSupervisor.create({
      data: {
        caso_id: TEST_CASE_ID,
        supervisor_id: ADMIN_USER_ID,
        version_revision: nextVersion,
        vigente: true,
        observaciones: `Prueba E7-03 - Versión ${nextVersion}`,
        resultado: ResultadoRevision.aprobado,
        creado_por: ADMIN_USER_ID,
      },
    });
  });

  log(`Nueva revisión creada: version_revision=${nuevaRevision.version_revision}`);

  // 2.3 Verificar incremento correcto
  if (nuevaRevision.version_revision === maxAntes + 1) {
    logPass('Prueba 2.1 - Incremento correcto', 
      `Versión ${maxAntes} → ${nuevaRevision.version_revision}`);
  } else {
    logFail('Prueba 2.1 - Incremento correcto', 
      `Esperaba ${maxAntes + 1}, obtuvo ${nuevaRevision.version_revision}`);
  }

  // 2.4 Verificar unicidad de secuencia
  const despues = await prisma.revisionSupervisor.findMany({
    where: { caso_id: TEST_CASE_ID },
    orderBy: { version_revision: 'asc' },
    select: { version_revision: true },
  });

  const versionesDespues = despues.map(r => r.version_revision);
  const uniqueVersiones = new Set(versionesDespues);

  if (uniqueVersiones.size === versionesDespues.length) {
    logPass('Prueba 2.2 - Secuencia sin duplicados', 
      `Versiones únicas: [${versionesDespues.join(', ')}]`);
  } else {
    logFail('Prueba 2.2 - Secuencia sin duplicados', 
      `Hay duplicados en: [${versionesDespues.join(', ')}]`);
  }

  // 2.5 Verificar que solo hay una vigente
  const vigentes = await prisma.revisionSupervisor.count({
    where: { caso_id: TEST_CASE_ID, vigente: true },
  });

  if (vigentes === 1) {
    logPass('Prueba 2.3 - Una sola vigente', 
      `Exactamente 1 revisión vigente`);
  } else {
    logFail('Prueba 2.3 - Una sola vigente', 
      `Hay ${vigentes} revisiones vigentes (esperaba 1)`);
  }
}

/**
 * PRUEBA 3 — Concurrencia controlada
 * Ejecutar dos intentos simultáneos y verificar que no hay colisión.
 */
async function prueba3_concurrencia(): Promise<void> {
  log('\n=== PRUEBA 3: CONCURRENCIA CONTROLADA ===\n');

  // 3.1 Estado inicial
  const antes = await prisma.revisionSupervisor.findFirst({
    where: { caso_id: TEST_CASE_ID },
    orderBy: { version_revision: 'desc' },
    select: { version_revision: true },
  });
  const maxAntes = antes?.version_revision ?? 0;
  log(`Versión máxima antes: ${maxAntes}`);

  // 3.2 Lanzar dos creaciones concurrentes
  log('Lanzando 2 creaciones concurrentes...');

  const crearRevision = async (label: string) => {
    return prisma.$transaction(async (tx) => {
      await tx.revisionSupervisor.updateMany({
        where: { caso_id: TEST_CASE_ID, vigente: true },
        data: { vigente: false },
      });

      const last = await tx.revisionSupervisor.findFirst({
        where: { caso_id: TEST_CASE_ID },
        orderBy: { version_revision: 'desc' },
        select: { version_revision: true },
      });
      const nextVersion = (last?.version_revision ?? 0) + 1;

      return tx.revisionSupervisor.create({
        data: {
          caso_id: TEST_CASE_ID,
          supervisor_id: ADMIN_USER_ID,
          version_revision: nextVersion,
          vigente: true,
          observaciones: `Prueba E7-03 concurrencia - ${label}`,
          resultado: ResultadoRevision.aprobado,
          creado_por: ADMIN_USER_ID,
        },
      });
    });
  };

  const resultados = await Promise.allSettled([
    crearRevision('Concurrent-A'),
    crearRevision('Concurrent-B'),
  ]);

  // 3.3 Analizar resultados
  let exitosos = 0;
  let fallidos = 0;
  const versionesCreadas: number[] = [];

  resultados.forEach((r, i) => {
    const label = i === 0 ? 'A' : 'B';
    if (r.status === 'fulfilled') {
      exitosos++;
      versionesCreadas.push(r.value.version_revision);
      log(`  [${label}] Éxito: version_revision=${r.value.version_revision}`);
    } else {
      fallidos++;
      const error = r.reason as any;
      log(`  [${label}] Fallo: ${error.code || error.message}`);
    }
  });

  // 3.4 Verificar comportamiento esperado
  // Caso ideal: ambos exitosos con versiones diferentes
  // Caso aceptable: uno exitoso, otro falla por constraint
  
  if (exitosos === 2 && versionesCreadas[0] !== versionesCreadas[1]) {
    logPass('Prueba 3.1 - Concurrencia resuelta', 
      `Ambos exitosos con versiones distintas: ${versionesCreadas.join(', ')}`);
  } else if (exitosos === 1 && fallidos === 1) {
    logPass('Prueba 3.1 - Concurrencia resuelta', 
      `Uno exitoso (v${versionesCreadas[0]}), otro rechazado por constraint`);
  } else if (exitosos === 2 && versionesCreadas[0] === versionesCreadas[1]) {
    logFail('Prueba 3.1 - Concurrencia resuelta', 
      `Ambos crearon misma versión: ${versionesCreadas[0]} — VIOLACIÓN DE UNICIDAD`);
  } else {
    logFail('Prueba 3.1 - Concurrencia resuelta', 
      `Resultado inesperado: ${exitosos} exitosos, ${fallidos} fallidos`);
  }

  // 3.5 Verificar estado final consistente
  const despues = await prisma.revisionSupervisor.findMany({
    where: { caso_id: TEST_CASE_ID },
    orderBy: { version_revision: 'asc' },
    select: { version_revision: true },
  });

  const versionesDespues = despues.map(r => r.version_revision);
  const uniqueVersiones = new Set(versionesDespues);

  if (uniqueVersiones.size === versionesDespues.length) {
    logPass('Prueba 3.2 - Estado final consistente', 
      `Sin duplicados: [${versionesDespues.join(', ')}]`);
  } else {
    logFail('Prueba 3.2 - Estado final consistente', 
      `Duplicados detectados: [${versionesDespues.join(', ')}]`);
  }
}

/**
 * MAIN
 */
async function main() {
  console.log('==============================================================================');
  console.log('E7-03 RUNTIME — VERIFICACIÓN HARDENING (caso_id, version_revision)');
  console.log('==============================================================================');
  console.log(`Caso de prueba: ${TEST_CASE_ID}`);
  console.log(`Usuario: ${ADMIN_USER_ID}`);

  try {
    await prueba1_unicidadReal();
    await prueba2_consistenciaFlujo();
    await prueba3_concurrencia();

    // Resumen
    console.log('\n==============================================================================');
    console.log('RESUMEN E7-03');
    console.log('==============================================================================');
    
    const passed = results.filter(r => r.passed).length;
    const failed = results.filter(r => !r.passed).length;
    
    console.log(`PASS: ${passed}`);
    console.log(`FAIL: ${failed}`);
    console.log(`TOTAL: ${results.length}`);
    console.log('==============================================================================');

    if (failed > 0) {
      console.log('\nFALLOS:');
      results.filter(r => !r.passed).forEach(r => {
        console.log(`  - ${r.name}: ${r.detail}`);
      });
      process.exit(1);
    }

  } catch (error) {
    console.error('Error fatal:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

main();
