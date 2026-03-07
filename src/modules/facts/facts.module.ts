import { Module } from '@nestjs/common';
import { FactsController } from './facts.controller';
import { FactsService } from './facts.service';
import { FactsRepository } from './facts.repository';

@Module({
  controllers: [FactsController],
  providers: [
    FactsService,
    FactsRepository,
  ],
  exports: [FactsService],
})
export class FactsModule {}
