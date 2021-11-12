import { BaseError } from "@faults/fault";

export default class ValidationError extends BaseError {
  constructor(fault: { message: string; origin?: unknown }) {
    super({ type: "validation", ...fault });
  }
}
