import type { NextFunction, Request, Response } from 'express';
import type { Logger } from 'pino';
import { AppError, errorBody } from '../utils/errors';

type RequestWithLog = Request & { log?: Logger };

function isInvalidJson(err: unknown): boolean {
  if (!(err instanceof SyntaxError)) {
    return false;
  }
  const withStatus = err as SyntaxError & { status?: number; type?: string };
  return withStatus.status === 400 || withStatus.type === 'entity.parse.failed';
}

export function errorHandler(err: unknown, req: Request, res: Response, next: NextFunction): void {
  if (res.headersSent) {
    next(err);
    return;
  }

  if (isInvalidJson(err)) {
    res.status(400).json(errorBody('INVALID_JSON', 'Request body must be valid JSON'));
    return;
  }

  if (err instanceof AppError) {
    res.status(err.statusCode).json(errorBody(err.code, err.message));
    return;
  }

  (req as RequestWithLog).log?.error({ err }, 'unhandled error');
  res.status(500).json(errorBody('INTERNAL_ERROR', 'Something went wrong'));
}
