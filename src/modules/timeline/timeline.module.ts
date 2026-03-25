import { Module } from '@nestjs/common';
import { TimelineController } from './timeline.controller';
import { TimelineService } from './timeline.service';
import { TimelineRepository } from './timeline.repository';
import { PrismaModule } from '../../infrastructure/database/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [TimelineController],
  providers: [TimelineService, TimelineRepository],
  exports: [TimelineService],
})
export class TimelineModule {}
