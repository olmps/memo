import { BaseError } from "@faults/fault";

export default class SerializationError extends BaseError {
  constructor(fault: { message: string; origin?: unknown }) {
    super({ type: "serialization", ...fault });
  }
}
