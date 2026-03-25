import { Module } from '@nestjs/common';
import { StrategyController } from './strategy.controller';
import { StrategyService } from './strategy.service';
import { StrategyRepository } from './strategy.repository';
import { PrismaModule } from '../../infrastructure/database/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [StrategyController],
  providers: [StrategyService, StrategyRepository],
  exports: [StrategyService],
})
export class StrategyModule {}
