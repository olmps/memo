import { deepStrictEqual } from "assert";

/**
 * Compares if {@link a} has a deep-equality of value to {@link b}.
 *
 * Uses node's {@link deepStrictEqual}.
 */
export function objectsEqual(a: unknown, b: unknown): boolean {
  try {
    deepStrictEqual(a, b);
    return true;
  } catch (_) {
    return false;
  }
}
