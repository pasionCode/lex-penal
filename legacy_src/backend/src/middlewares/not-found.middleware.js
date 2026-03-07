export function notFoundMiddleware(req, res) {
  res.status(404).json({ ok: false, message: 'Ruta no encontrada' });
}
