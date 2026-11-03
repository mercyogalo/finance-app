import cors from 'cors';
import express, { type Express } from 'express';
import helmet from 'helmet';
import { env } from './config/env';
import { errorHandler } from './middleware/error-handler';
import { createHttpLogger } from './middleware/http-logger';
import { notFoundHandler } from './middleware/not-found';
import { createRateLimiter } from './middleware/rate-limit';
import { requestId } from './middleware/request-id';
import { healthRouter } from './modules/health/health.routes';
import { AppError } from './utils/errors';
import { logger } from './utils/logger';

export type CreateAppOptions = {
  rateLimitMax?: number;
  rateLimitWindowMs?: number;
};

export function createApp(options: CreateAppOptions = {}): Express {
  const app = express();

  app.disable('x-powered-by');
  app.use(requestId);
  app.use(createHttpLogger(logger));
  app.use(helmet());
  app.use(
    cors({
      origin(origin, callback) {
        if (origin === undefined || env.corsOrigins.includes(origin)) {
          callback(null, true);
          return;
        }
        callback(new AppError(403, 'CORS_FORBIDDEN', 'Origin is not allowed'));
      },
      credentials: true,
    }),
  );
  app.use(
    createRateLimiter({
      ...(options.rateLimitMax === undefined ? {} : { limit: options.rateLimitMax }),
      ...(options.rateLimitWindowMs === undefined ? {} : { windowMs: options.rateLimitWindowMs }),
    }),
  );
  app.use(express.json({ limit: '1mb' }));
  app.use(healthRouter);
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
