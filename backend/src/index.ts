import { createApp } from './app';
import { env } from './config/env';
import { startScheduler, stopScheduler } from './jobs/scheduler';
import { connectDatabase, disconnectDatabase } from './services/database';
import { logger } from './utils/logger';

const app = createApp();

async function main(): Promise<void> {
  await connectDatabase(env.MONGODB_URI);
  logger.info('database connected');
  startScheduler();

  const server = app.listen(env.PORT, env.HOST, () => {
    logger.info({ port: env.PORT, host: env.HOST }, 'api listening');
  });

  const shutdown = (signal: string): void => {
    logger.info({ signal }, 'shutting down');
    stopScheduler();
    server.close(() => {
      disconnectDatabase()
        .catch((error: unknown) => {
          const errorName = error instanceof Error ? error.name : 'Error';
          logger.error({ errorName }, 'error closing database');
        })
        .finally(() => {
          process.exit(0);
        });
    });
    setTimeout(() => {
      process.exit(1);
    }, 10_000).unref();
  };

  process.on('SIGINT', () => {
    shutdown('SIGINT');
  });
  process.on('SIGTERM', () => {
    shutdown('SIGTERM');
  });
}

main().catch((error: unknown) => {
  const errorName = error instanceof Error ? error.name : 'Error';
  logger.fatal({ errorName }, 'failed to start');
  process.exit(1);
});
