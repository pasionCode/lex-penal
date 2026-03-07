import { Module } from '@nestjs/common';
import { ClientBriefingController } from './client-briefing.controller';
import { ClientBriefingService } from './client-briefing.service';
import { ClientBriefingRepository } from './client-briefing.repository';

@Module({
  controllers: [ClientBriefingController],
  providers: [
    ClientBriefingService,
    ClientBriefingRepository,
  ],
  exports: [ClientBriefingService],
})
export class ClientBriefingModule {}
