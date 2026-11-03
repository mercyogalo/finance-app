import rateLimit from 'express-rate-limit';
import { env } from '../config/env';
import { errorBody } from '../utils/errors';

type RateLimiterOptions = {
  windowMs?: number;
  limit?: number;
};

export function createRateLimiter(options: RateLimiterOptions = {}) {
  return rateLimit({
    windowMs: options.windowMs ?? env.RATE_LIMIT_WINDOW_MS,
    limit: options.limit ?? env.RATE_LIMIT_MAX,
    standardHeaders: true,
    legacyHeaders: false,
    skip: (req) => req.path === '/health' || req.path === '/ready',
    handler: (_req, res) => {
      res.status(429).json(errorBody('RATE_LIMITED', 'Too many requests'));
    },
  });
}
