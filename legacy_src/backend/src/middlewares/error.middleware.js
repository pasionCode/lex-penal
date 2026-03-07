export function errorMiddleware(error, req, res, next) {
  console.error(error);
  res.status(error.statusCode || 500).json({
    ok: false,
    message: error.message || 'Error interno del servidor',
    requestId: req.requestId
  });
}
