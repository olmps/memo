import * as logger from "@google-cloud/logging";
import { BaseError, BaseException } from "@faults/fault";

/** Provides logging capabilities based on the running environment. */
export class Logger {
  readonly #logging = new logger.Logging().log("memo-firebase-functions");
  /** `true` if the application is running in a development environment. */
  readonly #isLocalDevelopment: boolean;

  constructor(isLocalDevelopment: boolean) {
    this.#isLocalDevelopment = isLocalDevelopment;
  }

  /** Logs {@link message} with `info` - the lowest - priority level. */
  async info(message: string): Promise<void> {
    if (this.#isLocalDevelopment) {
      console.info(message);
      return;
    }

    const entry = this.#logging.entry({ message });
    await this.#logging.info(entry);
  }

  /** Logs {@link message} with `warn` priority level. */
  async warn(message: string): Promise<void> {
    if (this.#isLocalDevelopment) {
      console.warn(message);
      return;
    }

    const entry = this.#logging.entry({ message });
    await this.#logging.warning(entry);
  }

  /** Logs {@link error} with `error` - the highest - priority level. */
  async error(error: BaseError): Promise<void> {
    if (this.#isLocalDevelopment) {
      console.error(error);
      return;
    }

    const entry = this.#logging.entry({
      type: error.type,
      message: error.message,
      origin: error.origin,
      stack: error.stack,
    });

    await this.#logging.error(entry);
  }

  /** Logs {@link exception} with `error` - the highest - priority level. */
  async exception(exception: BaseException): Promise<void> {
    if (this.#isLocalDevelopment) {
      console.error(exception);
      return;
    }

    const entry = this.#logging.entry({
      type: exception.type,
      message: exception.message,
    });

    await this.#logging.info(entry);
  }
}
