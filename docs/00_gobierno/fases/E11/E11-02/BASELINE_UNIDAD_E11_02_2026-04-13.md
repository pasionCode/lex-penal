# BASELINE UNIDAD E11-02 — 2026-04-13

## 1. Punto de partida
E11-02 inicia con evidencia de que LEX_PENAL ya corre como servicio persistente (`lex-penal.service`) y escucha en `*:3010`, pero sin verificación privilegiada completa de commit, proxy y smoke endpoint funcional.

## 2. Problema operativo actual
Existe backend activo, pero todavía no existe trazabilidad completa entre:
- código desplegado,
- servicio systemd,
- configuración Nginx,
- y ruta de validación funcional.

## 3. Resultado esperado
Cerrar la brecha entre servicio activo y publicación controlada verificable.
