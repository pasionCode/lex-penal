import express from 'express';
import cors from 'cors';
import routes from './routes/index.js';
import { env } from './config/env.js';
import { requestIdMiddleware } from './middlewares/request-id.middleware.js';
import { notFoundMiddleware } from './middlewares/not-found.middleware.js';
import { errorMiddleware } from './middlewares/error.middleware.js';

export function createApp() {
  const app = express();
  app.use(cors({ origin: env.corsOrigin }));
  app.use(express.json());
  app.use(requestIdMiddleware);
  app.use(routes);
  app.use(notFoundMiddleware);
  app.use(errorMiddleware);
  return app;
}
