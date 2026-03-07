import { SetMetadata } from '@nestjs/common';

export type UserRole = 'estudiante' | 'supervisor' | 'administrador';
export const ROLES_KEY = 'roles';

/** Declara los perfiles autorizados para una ruta. */
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
