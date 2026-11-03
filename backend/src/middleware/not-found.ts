import type { Request, Response } from 'express';
import { errorBody } from '../utils/errors';

export function notFoundHandler(req: Request, res: Response): void {
  res.status(404).json(errorBody('NOT_FOUND', `Route not found: ${req.method} ${req.path}`));
}
