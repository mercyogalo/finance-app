import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config({ quiet: true });

const nodeEnvSchema = z.enum(['development', 'test', 'production']);
const logLevelSchema = z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent']);
const payoutProviderSchema = z.enum(['mock', 'minisend']);
const smsProviderSchema = z.enum(['console', 'africastalking']);
const booleanStringSchema = z.enum(['true', 'false']);

const envSchema = z.object({
  NODE_ENV: nodeEnvSchema.default('development'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  HOST: z.string().min(1).default('0.0.0.0'),
  MONGODB_URI: z
    .string()
    .regex(/^mongodb(\+srv)?:\/\//, 'MONGODB_URI must be a mongodb:// or mongodb+srv:// URL'),
  LOG_LEVEL: logLevelSchema.default('info'),
  CORS_ORIGINS: z.string().min(1),
  DEMO_MODE: booleanStringSchema.default('false'),
  MOCK_AI: booleanStringSchema.default('true'),
  PAYOUT_PROVIDER: payoutProviderSchema.default('mock'),
  SMS_PROVIDER: smsProviderSchema.default('console'),
  X402_ENABLED: booleanStringSchema.default('false'),
  RATE_LIMIT_WINDOW_MS: z.coerce.number().int().positive().default(900_000),
  RATE_LIMIT_MAX: z.coerce.number().int().positive().default(100),
});

export type Env = {
  NODE_ENV: z.infer<typeof nodeEnvSchema>;
  PORT: number;
  HOST: string;
  MONGODB_URI: string;
  LOG_LEVEL: z.infer<typeof logLevelSchema>;
  CORS_ORIGINS: string;
  corsOrigins: string[];
  DEMO_MODE: boolean;
  MOCK_AI: boolean;
  PAYOUT_PROVIDER: z.infer<typeof payoutProviderSchema>;
  SMS_PROVIDER: z.infer<typeof smsProviderSchema>;
  X402_ENABLED: boolean;
  RATE_LIMIT_WINDOW_MS: number;
  RATE_LIMIT_MAX: number;
};

function blankToUndefined(value: string | undefined): string | undefined {
  if (value === undefined) {
    return undefined;
  }
  const trimmed = value.trim();
  return trimmed.length === 0 ? undefined : trimmed;
}

function read(source: NodeJS.ProcessEnv, key: string): string | undefined {
  return blankToUndefined(source[key]);
}

function formatIssues(error: z.ZodError): string {
  return error.issues
    .map((issue) => {
      const path = issue.path.length > 0 ? issue.path.join('.') : 'env';
      return `${path}: ${issue.message}`;
    })
    .join('\n');
}

/**
 * Reads process environment (after dotenv) and throws if it is invalid.
 * The process exits from the server entrypoint when this throws at startup.
 */
export function loadEnv(source: NodeJS.ProcessEnv = process.env): Env {
  const candidate = {
    NODE_ENV: read(source, 'NODE_ENV'),
    PORT: read(source, 'PORT'),
    HOST: read(source, 'HOST'),
    MONGODB_URI: read(source, 'MONGODB_URI'),
    LOG_LEVEL: read(source, 'LOG_LEVEL'),
    CORS_ORIGINS: read(source, 'CORS_ORIGINS'),
    DEMO_MODE: read(source, 'DEMO_MODE'),
    MOCK_AI: read(source, 'MOCK_AI'),
    PAYOUT_PROVIDER: read(source, 'PAYOUT_PROVIDER'),
    SMS_PROVIDER: read(source, 'SMS_PROVIDER'),
    X402_ENABLED: read(source, 'X402_ENABLED'),
    RATE_LIMIT_WINDOW_MS: read(source, 'RATE_LIMIT_WINDOW_MS'),
    RATE_LIMIT_MAX: read(source, 'RATE_LIMIT_MAX'),
  };

  const parsed = envSchema.safeParse(candidate);
  if (!parsed.success) {
    throw new Error(`Invalid environment configuration:\n${formatIssues(parsed.error)}`);
  }

  const corsOrigins = parsed.data.CORS_ORIGINS.split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);

  if (corsOrigins.length === 0) {
    throw new Error(
      'Invalid environment configuration:\nCORS_ORIGINS: at least one origin is required',
    );
  }

  const originCheck = z.string().url();
  for (const origin of corsOrigins) {
    const checked = originCheck.safeParse(origin);
    if (!checked.success) {
      throw new Error(
        `Invalid environment configuration:\nCORS_ORIGINS: "${origin}" must be an absolute http(s) URL`,
      );
    }
  }

  return {
    NODE_ENV: parsed.data.NODE_ENV,
    PORT: parsed.data.PORT,
    HOST: parsed.data.HOST,
    MONGODB_URI: parsed.data.MONGODB_URI,
    LOG_LEVEL: parsed.data.LOG_LEVEL,
    CORS_ORIGINS: parsed.data.CORS_ORIGINS,
    corsOrigins,
    DEMO_MODE: parsed.data.DEMO_MODE === 'true',
    MOCK_AI: parsed.data.MOCK_AI === 'true',
    PAYOUT_PROVIDER: parsed.data.PAYOUT_PROVIDER,
    SMS_PROVIDER: parsed.data.SMS_PROVIDER,
    X402_ENABLED: parsed.data.X402_ENABLED === 'true',
    RATE_LIMIT_WINDOW_MS: parsed.data.RATE_LIMIT_WINDOW_MS,
    RATE_LIMIT_MAX: parsed.data.RATE_LIMIT_MAX,
  };
}

function loadOrExit(): Env {
  try {
    return loadEnv();
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Invalid environment configuration';
    if (process.env.NODE_ENV === 'test') {
      throw error;
    }
    console.error(message);
    process.exit(1);
  }
}

export const env: Env = loadOrExit();
