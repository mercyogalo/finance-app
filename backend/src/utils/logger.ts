import pino from 'pino';
import { env } from '../config/env';

export const logger = pino({
  level: env.LOG_LEVEL,
  redact: {
    paths: [
      'req.headers.authorization',
      'req.headers.cookie',
      'res.headers["set-cookie"]',
      '*.password',
      '*.pin',
      '*.otp',
      '*.secret',
      '*.token',
      '*.idToken',
      '*.phone',
      '*.MONGODB_URI',
    ],
    censor: '[redacted]',
  },
});
