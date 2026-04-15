import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const usuarios = await prisma.usuario.findMany({
    take: 20,
    orderBy: { creado_en: 'asc' },
  });

  const casos = await prisma.caso.findMany({
    take: 20,
    orderBy: { creado_en: 'asc' },
  });

  console.log('=== USUARIOS ===');
  console.log(JSON.stringify(usuarios, null, 2));
  console.log();
  console.log('=== CASOS ===');
  console.log(JSON.stringify(casos, null, 2));
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
