import cron, { type ScheduledTask } from 'node-cron';
import { logger } from '../utils/logger';

const tasks: ScheduledTask[] = [];

/**
 * Jobs run inside this single API process.
 * Do not run more than one API instance, or scheduled work will run twice.
 */
export function scheduleJob(name: string, expression: string, task: () => void): void {
  if (!cron.validate(expression)) {
    throw new Error(`Invalid cron expression for job "${name}"`);
  }
  const scheduled = cron.schedule(
    expression,
    () => {
      try {
        task();
      } catch (error) {
        const errorName = error instanceof Error ? error.name : 'Error';
        logger.error({ job: name, errorName }, 'scheduled job failed');
      }
    },
    { name, unref: true },
  );
  tasks.push(scheduled);
  logger.info({ job: name, expression }, 'scheduled job registered');
}

export function startScheduler(): void {
  logger.info({ jobs: tasks.length }, 'scheduler started');
}

export function stopScheduler(): void {
  for (const task of tasks) {
    void task.stop();
  }
  tasks.length = 0;
}
