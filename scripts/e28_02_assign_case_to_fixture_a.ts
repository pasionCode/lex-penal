import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const updated = await prisma.caso.update({
    where: { id: 'b88b0c34-4150-4b4f-9fdf-752ec85206d6' },
    data: {
      responsable_id: '7b034bdd-b8ac-4fcb-87e4-e626ec6cbb5f',
      actualizado_por: '71e47a55-8803-4842-bf3c-c573bf2cc709'
    },
    select: {
      id: true,
      responsable_id: true,
      estado_actual: true,
      radicado: true
    }
  });

  console.log(JSON.stringify(updated, null, 2));
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
