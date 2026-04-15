import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const caso = await prisma.caso.findFirst({
    where: {
      estado_actual: {
        notIn: ['en_analisis', 'devuelto'],
      },
    },
    orderBy: { creado_en: 'asc' },
    select: {
      id: true,
      estado_actual: true,
      responsable_id: true,
      radicado: true,
    },
  });

  console.log(JSON.stringify(caso, null, 2));
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
