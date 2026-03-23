US-04 — Bootstrap de usuario base con rol
Nota de Validación y Cierre
Fecha: 2026-03-20
Jornada: 06
Sprint: 1
Estado: ✅ CERRADA

1. Objeto de la validación
La presente nota tiene por objeto dejar constancia de la implementación, validación técnica y cierre formal de la historia US-04 — Bootstrap de usuario base con rol, correspondiente al Sprint 1 (auth + users) de la Jornada 06 del proyecto LEX_PENAL.

La historia tuvo como finalidad garantizar la existencia de un usuario administrador base mediante un proceso automático, interno e idempotente, ejecutado al arranque de la aplicación y gobernado por variables de entorno.

2. Archivos intervenidos
Archivo	Destino	Acción
users.repository.ts	src/modules/users/	Reemplazado
users.service.ts	src/modules/users/	Reemplazado
users.module.ts	src/modules/users/	Reemplazado
bootstrap.service.ts	src/modules/users/	Creado
Constancia: users.controller.ts no fue modificado, conforme al diseño aprobado para US-04, al tratarse de un proceso interno de arranque sin exposición de endpoint HTTP adicional.

3. Variables de entorno incorporadas
Se incorporaron al archivo .env las variables necesarias para gobernar el proceso de bootstrap:

BOOTSTRAP_ADMIN_ENABLED=true
BOOTSTRAP_ADMIN_NAME="Administrador LEX_PENAL"
BOOTSTRAP_ADMIN_EMAIL="admin@lexpenal.local"
BOOTSTRAP_ADMIN_PASSWORD="CambiarEnProduccion_2026!"
4. Resultado de compilación e integración
Se ejecutó el proceso de compilación del backend mediante:

npm run build
Resultado: ✅ Compilación exitosa, sin errores.

Posteriormente, se ejecutó el arranque local de la aplicación mediante:

npm run start:dev
Resultado: ✅ Aplicación iniciada correctamente, con ejecución efectiva del servicio de bootstrap.

5. Validaciones ejecutadas
5.1. Validación de creación inicial
Durante el arranque de la aplicación, el sistema ejecutó el proceso de bootstrap y registró la creación exitosa del usuario administrador base.

Evidencia de log:

[BootstrapService] Iniciando proceso de bootstrap de usuarios...
[BootstrapService] ✅ Usuario bootstrap administrador creado: admin@lexpenal.local
[BootstrapService] Proceso de bootstrap de usuarios completado
[NestApplication] Nest application successfully started
Resultado: ✅ SUPERADA

5.2. Validación en base de datos
Se verificó en Prisma Studio la persistencia correcta del usuario bootstrap, constatando los siguientes atributos:

Campo	Valor observado	Estado
email	admin@lexpenal.local	✅
nombre	Administrador LEX_PENAL	✅
perfil	administrador	✅
activo	true	✅
creado_por	null	✅
password_hash	Hash bcrypt persistido	✅
Resultado: ✅ SUPERADA

5.3. Validación de idempotencia
Se reinició la aplicación con el mismo archivo .env, verificando que el proceso no generara un segundo usuario y reconociera que la condición ya estaba satisfecha.

Evidencia de log:

[BootstrapService] Iniciando proceso de bootstrap de usuarios...
[BootstrapService] ⏭️ Usuario bootstrap ya existe: admin@lexpenal.local
[BootstrapService] Proceso de bootstrap de usuarios completado
[NestApplication] Nest application successfully started
Resultado: ✅ SUPERADA

5.4. Validación de no duplicidad
Se verificó nuevamente en Prisma Studio que el modelo Usuario continuara mostrando un único registro.

Evidencia: tabla Usuario con indicador “Showing 1 of 1”.

Resultado: ✅ SUPERADA

6. Observaciones técnicas relevantes
Se implementó el bootstrap como servicio interno de arranque, sin apertura de endpoint HTTP nuevo.

Se incorporó validación de consistencia para impedir creación en caso de conflicto de email con perfil distinto.

Se reforzaron validaciones mínimas en users.service.ts, incluyendo longitud mínima de contraseña y validación básica de formato de email.

Se centralizó la normalización de email en la capa de servicio.

Se resolvió el ajuste de tipos requerido por TypeScript mediante validación previa y non-null assertions en el punto de invocación.

Se eliminó duplicidad de logs de error en bootstrap.service.ts, dejando una traza más limpia.

Se mantuvo intacto users.controller.ts, respetando el alcance autorizado de la historia.

7. Escenarios cubiertos por la implementación
Escenario	Comportamiento esperado	Estado
Base sin administradores	Crea usuario bootstrap	✅ Verificado
Bootstrap ya creado	Omite creación y registra existencia previa	✅ Verificado
Bootstrap deshabilitado	No crea usuario	✅ Implementado
Faltan variables de entorno	Falla con error explícito de configuración	✅ Implementado
Email existente con perfil distinto	Detecta inconsistencia crítica	✅ Implementado
Existencia previa de otro administrador	Omite nueva creación	✅ Implementado
8. Criterios de aceptación
Criterio	Estado
Creación automática del usuario administrador base	✅
Ejecución al arranque de la aplicación	✅
Comportamiento idempotente	✅
Contraseña almacenada como hash	✅
creado_por = null en usuario bootstrap	✅
Sin endpoint HTTP adicional	✅
Gobernado por variables de entorno	✅
Detección de inconsistencias	✅
Respeto por administrador previo existente	✅
9. Definition of Done
 Archivos intervenidos correctamente en src/modules/users/

 Variables de entorno incorporadas al .env

 npm run build ejecutado sin errores

 npm run start:dev ejecutado correctamente

 Creación inicial del administrador bootstrap verificada

 Persistencia correcta en base de datos verificada

 Idempotencia verificada en segundo arranque

 Ausencia de duplicados verificada

 Sin modificación de users.controller.ts

10. Conclusión
US-04 — Bootstrap de usuario base con rol queda formalmente CERRADA.

Se implementó y validó exitosamente un mecanismo automático, interno e idempotente para garantizar la existencia de un usuario administrador base en el sistema. La solución quedó integrada al arranque de la aplicación, gobernada por variables de entorno, sin exponer endpoints adicionales y con evidencia suficiente de creación inicial, persistencia correcta, idempotencia y ausencia de duplicados.

11. Habilitación del siguiente paso
Con el cierre de US-04, quedan satisfechas las precondiciones técnicas para avanzar a la historia:

US-01 — Iniciar sesión

Precondiciones verificadas:

usuario bootstrap existente en base de datos ✅

password_hash persistido correctamente ✅

UsersService.findByEmail() operativo ✅

UsersService.verifyPassword() disponible ✅