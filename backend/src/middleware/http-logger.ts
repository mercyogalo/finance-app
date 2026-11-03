import type { Logger } from 'pino';
import { pinoHttp } from 'pino-http';

export function createHttpLogger(logger: Logger) {
  return pinoHttp({
    logger,
    genReqId: (req) => {
      const requestWithId = req as typeof req & { id?: string };
      return requestWithId.id ?? 'unknown';
    },
    autoLogging: {
      ignore: (req) => req.url === '/health' || req.url === '/ready',
    },
  });
}
