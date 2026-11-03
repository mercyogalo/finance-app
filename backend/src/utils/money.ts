import { AppError } from './errors';

/** Kenyan shilling amounts are integer cents. 1 KES = 100 cents. Never use floats. */
export const CENTS_PER_KES = 100;

export function assertKesCents(amount: number, field = 'amount'): number {
  if (!Number.isSafeInteger(amount)) {
    throw new AppError(400, 'INVALID_AMOUNT', `${field} must be an integer number of cents`);
  }
  if (amount < 0) {
    throw new AppError(400, 'INVALID_AMOUNT', `${field} cannot be negative`);
  }
  return amount;
}
