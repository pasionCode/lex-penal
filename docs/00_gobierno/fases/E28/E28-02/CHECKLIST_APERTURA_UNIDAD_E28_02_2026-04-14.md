# CHECKLIST APERTURA UNIDAD E28-02 — 2026-04-14

## 1. Identificación
- Fase: E28
- Unidad: E28-02
- Fecha de apertura: 2026-04-14
- Estado: ABIERTA

## 2. Objetivo de la unidad
Construir un fixture reutilizable de seguridad para validar respuestas `403 Forbidden` entre estudiantes en recursos case-scoped, evitando dependencia de datos manuales o improvisados durante pruebas runtime.

## 3. Alcance
- Identificar o provisionar:
  - un estudiante A;
  - un estudiante B;
  - un caso propiedad de A en estado escribible.
- Obtener tokens reales de A y B vía login.
- Verificar `403` de B sobre el caso de A en al menos un recurso representativo.
- Dejar script reutilizable para futuras validaciones de aislamiento.

## 4. Criterios de aceptación
- Existe script de fixture que detecta o crea el escenario mínimo.
- Existe script runtime que prueba `403` con usuario no propietario.
- Se documentan credenciales técnicas de prueba solo si ya existen en entorno local controlado.
- La unidad deja evidencia reproducible en `docs/00_gobierno/fases/E28/E28-02/evidencias/`.

## 5. Exclusiones
- No se modifica lógica funcional del backend salvo que se detecte un defecto real.
- No se reabre E28-01.
