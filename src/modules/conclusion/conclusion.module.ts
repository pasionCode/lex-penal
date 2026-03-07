import { Module } from '@nestjs/common';
import { ConclusionController } from './conclusion.controller';
import { ConclusionService } from './conclusion.service';
import { ConclusionRepository } from './conclusion.repository';

@Module({
  controllers: [ConclusionController],
  providers: [
    ConclusionService,
    ConclusionRepository,
  ],
  exports: [ConclusionService],
})
export class ConclusionModule {}
