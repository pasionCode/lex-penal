import { Module } from '@nestjs/common';
import { StrategyController } from './strategy.controller';
import { TimelineController } from './timeline.controller';
import { StrategyService } from './strategy.service';
import { StrategyRepository } from './strategy.repository';

@Module({
  controllers: [StrategyController, TimelineController],
  providers: [StrategyService, StrategyRepository],
  exports: [StrategyService],
})
export class StrategyModule {}
