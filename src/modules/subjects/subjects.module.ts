import { Module } from '@nestjs/common';
import { SubjectsController } from './subjects.controller';
import { SubjectsService } from './subjects.service';
import { SubjectsRepository } from './subjects.repository';
import { PrismaModule } from '../../infrastructure/database/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [SubjectsController],
  providers: [SubjectsService, SubjectsRepository],
  exports: [SubjectsService],
})
export class SubjectsModule {}
