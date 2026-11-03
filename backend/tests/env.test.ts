import { loadEnv } from '../src/config/env';

const valid: NodeJS.ProcessEnv = {
  MONGODB_URI: 'mongodb://127.0.0.1:27017/hifadhi',
  CORS_ORIGINS: 'http://localhost:3000, http://localhost:8080',
};

describe('loadEnv', () => {
  it('applies safe defaults and parses the feature switches', () => {
    const config = loadEnv(valid);

    expect(config.NODE_ENV).toBe('development');
    expect(config.PORT).toBe(3000);
    expect(config.DEMO_MODE).toBe(false);
    expect(config.MOCK_AI).toBe(true);
    expect(config.PAYOUT_PROVIDER).toBe('mock');
    expect(config.SMS_PROVIDER).toBe('console');
    expect(config.X402_ENABLED).toBe(false);
    expect(config.corsOrigins).toEqual(['http://localhost:3000', 'http://localhost:8080']);
  });

  it('accepts the documented switch values', () => {
    const config = loadEnv({
      ...valid,
      DEMO_MODE: 'true',
      MOCK_AI: 'false',
      PAYOUT_PROVIDER: 'minisend',
      SMS_PROVIDER: 'africastalking',
      X402_ENABLED: 'true',
    });

    expect(config.DEMO_MODE).toBe(true);
    expect(config.MOCK_AI).toBe(false);
    expect(config.PAYOUT_PROVIDER).toBe('minisend');
    expect(config.SMS_PROVIDER).toBe('africastalking');
    expect(config.X402_ENABLED).toBe(true);
  });

  it('fails fast when a required value or switch is invalid', () => {
    expect(() => loadEnv({ CORS_ORIGINS: 'http://localhost:3000' })).toThrow(/MONGODB_URI/);
    expect(() => loadEnv({ ...valid, PAYOUT_PROVIDER: 'stripe' })).toThrow(/PAYOUT_PROVIDER/);
    expect(() => loadEnv({ ...valid, DEMO_MODE: 'yes' })).toThrow(/DEMO_MODE/);
    expect(() => loadEnv({ ...valid, CORS_ORIGINS: 'localhost' })).toThrow(/CORS_ORIGINS/);
    expect(() => loadEnv({ ...valid, MONGODB_URI: 'http://localhost/db' })).toThrow(/MONGODB_URI/);
  });
});
