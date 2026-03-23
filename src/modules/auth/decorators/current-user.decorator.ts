import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { JwtPayload } from '../strategies/jwt.strategy';

/**
 * Decorador para extraer el usuario autenticado del request.
 * 
 * Uso completo (retorna todo el payload):
 * @CurrentUser() user: JwtPayload
 * 
 * Uso con propiedad específica:
 * @CurrentUser('sub') userId: string
 * @CurrentUser('email') email: string
 * @CurrentUser('perfil') perfil: string
 * 
 * Requiere que la ruta esté protegida con @UseGuards(JwtAuthGuard)
 */
export const CurrentUser = createParamDecorator(
  (data: keyof JwtPayload | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as JwtPayload;

    if (!user) {
      return null;
    }

    return data ? user[data] : user;
  },
);
