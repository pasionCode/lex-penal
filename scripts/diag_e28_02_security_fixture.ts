import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const estudiantes = await prisma.usuario.findMany({
    where: {
      perfil: 'estudiante',
      activo: true,
    },
    select: {
      id: true,
      nombre: true,
      email: true,
      perfil: true,
      activo: true,
      creado_en: true,
    },
    orderBy: { creado_en: 'asc' },
    take: 20,
  });

  const casosEscribibles = await prisma.caso.findMany({
    where: {
      estado_actual: { in: ['en_analisis', 'devuelto'] },
    },
    select: {
      id: true,
      radicado: true,
      responsable_id: true,
      estado_actual: true,
      creado_en: true,
    },
    orderBy: { creado_en: 'asc' },
    take: 50,
  });

  console.log('=== ESTUDIANTES ACTIVOS ===');
  console.log(JSON.stringify(estudiantes, null, 2));
  console.log();
  console.log('=== CASOS ESCRIBIBLES ===');
  console.log(JSON.stringify(casosEscribibles, null, 2));
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
