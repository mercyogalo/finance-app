import { AppError } from '../src/utils/errors';
import { assertKesCents, CENTS_PER_KES } from '../src/utils/money';

describe('money', () => {
  it('stores one shilling as 100 cents', () => {
    expect(CENTS_PER_KES).toBe(100);
    expect(assertKesCents(125_000)).toBe(125_000);
    expect(assertKesCents(0)).toBe(0);
  });

  it('rejects floats and negative amounts', () => {
    expect(() => assertKesCents(10.5)).toThrow(AppError);
    expect(() => assertKesCents(-1)).toThrow(AppError);
    try {
      assertKesCents(1.2, 'targetAmount');
    } catch (error) {
      expect(error).toBeInstanceOf(AppError);
      expect((error as AppError).code).toBe('INVALID_AMOUNT');
      expect((error as AppError).message).toMatch(/targetAmount/);
    }
  });
});
