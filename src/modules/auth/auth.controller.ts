import { Body, Controller, Get, Post, Res } from '@nestjs/common';
import { Response } from 'express';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { SessionResponseDto } from './dto/session-response.dto';

/** POST /api/v1/auth/login · POST /api/v1/auth/logout · GET /api/v1/auth/session */
@Controller('api/v1/auth')
export class AuthController {
  constructor(private readonly service: AuthService) {}

  @Post('login')
  login(@Body() _dto: LoginDto, @Res() _res: Response): Promise<void> {
    throw new Error('not implemented');
  }

  @Post('logout')
  logout(@Res() _res: Response): Promise<void> {
    throw new Error('not implemented');
  }

  @Get('session')
  session(): Promise<SessionResponseDto> {
    throw new Error('not implemented');
  }
}
