import { BaseError } from "#faults/fault";

export default class FilesystemError extends BaseError {
  constructor(fault: { message: string; origin?: unknown }) {
    super({ type: "file-system", ...fault });
  }
}
