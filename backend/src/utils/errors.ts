export class AppError extends Error {
  readonly statusCode: number;
  readonly code: string;

  constructor(statusCode: number, code: string, message: string) {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.code = code;
  }
}

export type ErrorBody = {
  error: {
    code: string;
    message: string;
  };
};

export function errorBody(code: string, message: string): ErrorBody {
  return { error: { code, message } };
}
