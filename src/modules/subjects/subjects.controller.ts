import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  Request,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { SubjectsService } from './subjects.service';
import { CreateSubjectDto } from './dto/create-subject.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('cases/:caseId/subjects')
@UseGuards(JwtAuthGuard)
export class SubjectsController {
  constructor(private readonly service: SubjectsService) {}

  @Get()
  async findAll(@Param('caseId', ParseUUIDPipe) caseId: string) {
    return this.service.findAllByCaseId(caseId);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Body() dto: CreateSubjectDto,
    @Request() req: any,
  ) {
    return this.service.create(caseId, dto, req.user.sub);
  }

  @Get(':subjectId')
  async findOne(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Param('subjectId', ParseUUIDPipe) subjectId: string,
  ) {
    return this.service.findOne(caseId, subjectId);
  }
}
