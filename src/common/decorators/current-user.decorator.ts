import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/**
 * Extrae el usuario autenticado del request.
 * Requiere JwtAuthGuard activo en la ruta.
 */
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext) => {
    throw new Error('not implemented');
  },
);
