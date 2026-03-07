import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  app.useGlobalFilters(new HttpExceptionFilter());
  const port = process.env.PORT ?? 3001;
  await app.listen(port);
  console.log(`LexPenal backend running on port ${port}`);
}

bootstrap();
