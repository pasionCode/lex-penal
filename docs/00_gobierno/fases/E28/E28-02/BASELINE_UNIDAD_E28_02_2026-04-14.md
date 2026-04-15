# BASELINE UNIDAD E28-02 — 2026-04-14

## 1. Punto de partida
La unidad E28-01 quedó cerrada con validación runtime suficiente del módulo `risks`, incluyendo respuestas `200`, `400`, `404` y `409`.

## 2. Brecha remanente
Quedó pendiente la validación `403` entre estudiante propietario y estudiante no propietario por ausencia de fixture runtime reutilizable.

## 3. Hipótesis de trabajo
La falta no corresponde a un defecto probado del backend sino a una carencia de infraestructura de prueba.

## 4. Estrategia
Resolver la brecha mediante fixture controlado:
- inventario de estudiantes existentes;
- detección o creación de caso escribible para uno de ellos;
- login automatizado de ambos;
- prueba explícita `403` contra recurso case-scoped.

## 5. Resultado esperado
Cerrar E28-02 con harness reutilizable para futuras pruebas de aislamiento.
