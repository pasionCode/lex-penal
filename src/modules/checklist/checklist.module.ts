import { Module } from '@nestjs/common';
import { ChecklistController } from './checklist.controller';
import { ChecklistService } from './checklist.service';
import { ChecklistRepository } from './checklist.repository';

@Module({
  controllers: [ChecklistController],
  providers: [
    ChecklistService,
    ChecklistRepository,
  ],
  exports: [ChecklistService],
})
export class ChecklistModule {}
