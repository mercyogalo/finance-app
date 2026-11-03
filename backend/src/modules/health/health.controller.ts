import type { Request, Response } from 'express';
import { pingDatabase } from '../../services/database';
import { errorBody } from '../../utils/errors';

export function getHealth(_req: Request, res: Response): void {
  res.status(200).json({ status: 'ok' });
}

export async function getReadiness(_req: Request, res: Response): Promise<void> {
  const ready = await pingDatabase();
  if (!ready) {
    res.status(503).json(errorBody('NOT_READY', 'Database is unavailable'));
    return;
  }
  res.status(200).json({ status: 'ready' });
}
