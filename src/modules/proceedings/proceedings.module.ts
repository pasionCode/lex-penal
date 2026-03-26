import { Module } from '@nestjs/common';
import { ProceedingsController } from './proceedings.controller';
import { ProceedingsService } from './proceedings.service';
import { ProceedingsRepository } from './proceedings.repository';
import { PrismaModule } from '../../infrastructure/database/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [ProceedingsController],
  providers: [ProceedingsService, ProceedingsRepository],
  exports: [ProceedingsService],
})
export class ProceedingsModule {}
