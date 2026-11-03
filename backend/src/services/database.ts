import mongoose from 'mongoose';
import { logger } from '../utils/logger';

export async function connectDatabase(uri: string): Promise<void> {
  mongoose.set('strictQuery', true);
  await mongoose.connect(uri);
}

export async function disconnectDatabase(): Promise<void> {
  if (mongoose.connection.readyState === 0) {
    return;
  }
  await mongoose.disconnect();
}

export async function pingDatabase(): Promise<boolean> {
  try {
    if (mongoose.connection.readyState !== 1 || !mongoose.connection.db) {
      return false;
    }
    const result = await mongoose.connection.db.admin().command({ ping: 1 });
    return result.ok === 1;
  } catch (error) {
    const name = error instanceof Error ? error.name : 'Error';
    logger.warn({ name }, 'database ping failed');
    return false;
  }
}
