import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { SubjectsService } from './subjects.service';
import { CreateSubjectDto, ListSubjectsQueryDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('cases/:caseId/subjects')
@UseGuards(JwtAuthGuard)
export class SubjectsController {
  constructor(private readonly service: SubjectsService) {}

  @Get()
  async findAll(
    @Param('caseId', ParseUUIDPipe) caseId: string,
    @Query() query: ListSubjectsQueryDto,
  ) {
    const page = query.page ?? 1;
    const perPage = query.per_page ?? 20;
    return this.service.findAllByCaseId(caseId, page, perPage, query.tipo, query.nombre);
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
