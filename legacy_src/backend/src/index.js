import { createApp } from './app.js';
import { env } from './config/env.js';
import { logger } from './config/logger.js';

const app = createApp();
app.listen(env.port, () => {
  logger.info('Backend iniciado', { port: env.port, environment: env.nodeEnv });
});
