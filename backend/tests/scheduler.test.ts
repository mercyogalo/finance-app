import { scheduleJob, stopScheduler } from '../src/jobs/scheduler';

describe('scheduler', () => {
  afterEach(() => {
    stopScheduler();
  });

  it('rejects an invalid cron expression before registering a job', () => {
    expect(() => scheduleJob('sample', 'not a cron', () => undefined)).toThrow(
      /Invalid cron expression/,
    );
  });

  it('registers a valid expression', () => {
    expect(() => scheduleJob('sample', '0 0 * * *', () => undefined)).not.toThrow();
  });
});
