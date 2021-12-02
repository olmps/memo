import { BaseError } from "#faults/fault";

export default class ShellError extends BaseError {
  constructor(fault: { message: string; origin?: unknown }) {
    super({ type: "shell", ...fault });
  }
}
