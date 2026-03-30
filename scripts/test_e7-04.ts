/**
 * ==============================================================================
 * E7-04 RUNTIME — VALIDACIÓN SEMÁNTICA CLIENT-BRIEFING
 * ==============================================================================
 * Proyecto: LEX_PENAL
 * Fase: E7
 * Unidad: E7-04
 * Fecha: 2026-03-30
 * ==============================================================================
 * 
 * Pruebas:
 * 1. Estado no permitido + no existe → 409
 * 2. Estado no permitido + existe → 200
 * 3. Estado permitido + no existe → 200 (auto-crea)
 * 4. Estado permitido + existe → 200
 * 5. PUT en estado permitido → 200
 * 6. PUT en estado no permitido → 409
 * 
 * Ejecutar: npx ts-node scripts/test_e7-04.ts
 * ==============================================================================
 */

import { PrismaClient, EstadoCaso } from '@prisma/client';

const prisma = new PrismaClient();

const BASE_URL = process.env.BASE_URL || 'http://localhost:3001/api/v1';
const TEST_CASE_ID = 'c9f0c313-1042-42f7-8371-faa89fd84f42';

interface TestResult {
  name: string;
  passed: boolean;
  detail: string;
}

const results: TestResult[] = [];
let TOKEN = '';

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

async function authenticate(): Promise<void> {
  log('=== AUTENTICACIÓN ===\n');
  
  const response = await fetch(`${BASE_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'admin@lexpenal.local',
      password: 'CambiarEnProduccion_2026!',
    }),
  });

  const data = await response.json();
  TOKEN = data.access_token;

  if (!TOKEN) {
    throw new Error('No se pudo obtener token');
  }
  log(`Token obtenido (${TOKEN.length} chars)\n`);
}

async function setEstadoCaso(estado: EstadoCaso): Promise<void> {
  await prisma.caso.update({
    where: { id: TEST_CASE_ID },
    data: { estado_actual: estado },
  });
  log(`  Estado del caso cambiado a: ${estado}`);
}

async function deleteClientBriefing(): Promise<void> {
  await prisma.explicacionCliente.deleteMany({
    where: { caso_id: TEST_CASE_ID },
  });
  log(`  Client-briefing eliminado (si existía)`);
}

async function clientBriefingExists(): Promise<boolean> {
  const briefing = await prisma.explicacionCliente.findUnique({
    where: { caso_id: TEST_CASE_ID },
  });
  return briefing !== null;
}

async function getClientBriefing(): Promise<{ status: number; body: any }> {
  const response = await fetch(`${BASE_URL}/cases/${TEST_CASE_ID}/client-briefing`, {
    method: 'GET',
    headers: { 'Authorization': `Bearer ${TOKEN}` },
  });
  const body = await response.json();
  return { status: response.status, body };
}

async function putClientBriefing(data: object): Promise<{ status: number; body: any }> {
  const response = await fetch(`${BASE_URL}/cases/${TEST_CASE_ID}/client-briefing`, {
    method: 'PUT',
    headers: { 
      'Authorization': `Bearer ${TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });
  const body = await response.json();
  return { status: response.status, body };
}

/**
 * PRUEBA 1: Estado no permitido + no existe → 409
 */
async function prueba1(): Promise<void> {
  log('\n=== PRUEBA 1: Estado NO permitido + NO existe → 409 ===\n');

  // Preparar: estado BORRADOR (no permitido), sin briefing
  await setEstadoCaso(EstadoCaso.borrador);
  await deleteClientBriefing();

  // Ejecutar GET
  const { status, body } = await getClientBriefing();
  log(`  GET /client-briefing → ${status}`);

  // Verificar
  if (status === 409) {
    logPass('Prueba 1 - GET en estado no permitido sin briefing', 
      'Retorna 409 Conflict');
  } else {
    logFail('Prueba 1 - GET en estado no permitido sin briefing', 
      `Esperaba 409, obtuvo ${status}`);
  }

  // Verificar que NO se creó
  const existe = await clientBriefingExists();
  if (!existe) {
    logPass('Prueba 1.1 - No auto-creó en estado no permitido', 
      'Briefing no existe en DB');
  } else {
    logFail('Prueba 1.1 - No auto-creó en estado no permitido', 
      'Briefing fue creado incorrectamente');
  }
}

/**
 * PRUEBA 2: Estado no permitido + existe → 200 (lectura permitida)
 */
async function prueba2(): Promise<void> {
  log('\n=== PRUEBA 2: Estado NO permitido + SÍ existe → 200 ===\n');

  // Preparar: crear briefing primero en estado permitido
  await setEstadoCaso(EstadoCaso.en_analisis);
  await deleteClientBriefing();
  
  // Crear briefing
  const createResult = await getClientBriefing();
  log(`  Creado briefing en estado permitido: ${createResult.status}`);

  // Cambiar a estado no permitido
  await setEstadoCaso(EstadoCaso.borrador);

  // Ejecutar GET
  const { status, body } = await getClientBriefing();
  log(`  GET /client-briefing → ${status}`);

  // Verificar
  if (status === 200) {
    logPass('Prueba 2 - GET en estado no permitido con briefing existente', 
      'Retorna 200 (lectura permitida)');
  } else {
    logFail('Prueba 2 - GET en estado no permitido con briefing existente', 
      `Esperaba 200, obtuvo ${status}`);
  }
}

/**
 * PRUEBA 3: Estado permitido + no existe → 200 (auto-crea)
 */
async function prueba3(): Promise<void> {
  log('\n=== PRUEBA 3: Estado SÍ permitido + NO existe → 200 (auto-crea) ===\n');

  // Preparar: estado EN_ANALISIS (permitido), sin briefing
  await setEstadoCaso(EstadoCaso.en_analisis);
  await deleteClientBriefing();

  const existeAntes = await clientBriefingExists();
  log(`  Briefing existe antes: ${existeAntes}`);

  // Ejecutar GET
  const { status, body } = await getClientBriefing();
  log(`  GET /client-briefing → ${status}`);

  // Verificar
  if (status === 200) {
    logPass('Prueba 3 - GET en estado permitido sin briefing', 
      'Retorna 200');
  } else {
    logFail('Prueba 3 - GET en estado permitido sin briefing', 
      `Esperaba 200, obtuvo ${status}`);
  }

  // Verificar que SÍ se creó
  const existeDespues = await clientBriefingExists();
  if (existeDespues) {
    logPass('Prueba 3.1 - Auto-creó en estado permitido', 
      'Briefing existe en DB');
  } else {
    logFail('Prueba 3.1 - Auto-creó en estado permitido', 
      'Briefing no fue creado');
  }
}

/**
 * PRUEBA 4: Estado permitido + existe → 200
 */
async function prueba4(): Promise<void> {
  log('\n=== PRUEBA 4: Estado SÍ permitido + SÍ existe → 200 ===\n');

  // Ya existe del prueba 3, solo cambiar estado para asegurar
  await setEstadoCaso(EstadoCaso.listo_para_cliente);

  // Ejecutar GET
  const { status, body } = await getClientBriefing();
  log(`  GET /client-briefing → ${status}`);

  // Verificar
  if (status === 200) {
    logPass('Prueba 4 - GET en estado permitido con briefing existente', 
      'Retorna 200');
  } else {
    logFail('Prueba 4 - GET en estado permitido con briefing existente', 
      `Esperaba 200, obtuvo ${status}`);
  }
}

/**
 * PRUEBA 5: PUT en estado permitido → 200
 */
async function prueba5(): Promise<void> {
  log('\n=== PRUEBA 5: PUT en estado SÍ permitido → 200 ===\n');

  await setEstadoCaso(EstadoCaso.en_analisis);

  // Ejecutar PUT
  const { status, body } = await putClientBriefing({
    delito_explicado: 'Prueba E7-04 - delito explicado',
  });
  log(`  PUT /client-briefing → ${status}`);

  // Verificar
  if (status === 200) {
    logPass('Prueba 5 - PUT en estado permitido', 
      'Retorna 200');
  } else {
    logFail('Prueba 5 - PUT en estado permitido', 
      `Esperaba 200, obtuvo ${status}`);
  }
}

/**
 * PRUEBA 6: PUT en estado no permitido → 409
 */
async function prueba6(): Promise<void> {
  log('\n=== PRUEBA 6: PUT en estado NO permitido → 409 ===\n');

  await setEstadoCaso(EstadoCaso.borrador);

  // Ejecutar PUT
  const { status, body } = await putClientBriefing({
    delito_explicado: 'No debería funcionar',
  });
  log(`  PUT /client-briefing → ${status}`);

  // Verificar
  if (status === 409) {
    logPass('Prueba 6 - PUT en estado no permitido', 
      'Retorna 409 Conflict');
  } else {
    logFail('Prueba 6 - PUT en estado no permitido', 
      `Esperaba 409, obtuvo ${status}`);
  }
}

/**
 * CLEANUP: Restaurar estado original
 */
async function cleanup(): Promise<void> {
  log('\n=== CLEANUP ===\n');
  
  // Restaurar a un estado razonable
  await setEstadoCaso(EstadoCaso.en_analisis);
  log('  Estado restaurado a en_analisis');
}

/**
 * MAIN
 */
async function main() {
  console.log('==============================================================================');
  console.log('E7-04 RUNTIME — VALIDACIÓN SEMÁNTICA CLIENT-BRIEFING');
  console.log('==============================================================================');
  console.log(`Caso de prueba: ${TEST_CASE_ID}`);
  console.log(`Base URL: ${BASE_URL}`);

  try {
    await authenticate();

    await prueba1();
    await prueba2();
    await prueba3();
    await prueba4();
    await prueba5();
    await prueba6();

    await cleanup();

    // Resumen
    console.log('\n==============================================================================');
    console.log('RESUMEN E7-04');
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
