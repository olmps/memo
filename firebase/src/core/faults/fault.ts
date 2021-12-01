/** Common interface between any fault, such as {@link Error} and {@link Exception}. */
export interface Fault {
  type: string;
  message?: string;
}

/** Core {@link Error} class that every custom error should extend from. */
export class BaseError extends Error implements Fault {
  public readonly type;
  public readonly origin;

  constructor({ type, message, origin }: Fault & { type: ErrorType; origin?: unknown }) {
    super(message);
    this.type = type;
    this.origin = origin;

    if (origin instanceof Error && origin.stack) {
      this.stack = `${this.stack!.split("\n").slice(0, 2).join("\n")}\n${origin.stack}`;
    }
  }
}

/** Core exception class that every custom exception should extend from. */
export class BaseException implements Fault {
  public readonly type;
  public readonly message?: string;

  constructor({ type, message }: Fault & { type: ExceptionType }) {
    this.type = type;
    this.message = message;
  }
}

/**
 * Codes for custom faults, composed of both errors and exceptions.
 *
 * @see ErrorType
 * @see ExceptionType
 */
export type FaultType = ErrorType | ExceptionType;

/** Codes for custom errors. */
type ErrorType = "file-system" | `firebase/${FirebaseService}` | "serialization" | "validation" | "shell";
type FirebaseService = "firestore";

/** Codes for custom exceptions. */
type ExceptionType = "http-exception";
