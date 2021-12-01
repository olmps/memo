import { BaseException } from "@faults/fault";

export default class HttpException extends BaseException {
  constructor(fault: { message: string; origin?: unknown }) {
    super({ type: "http-exception", ...fault });
  }
}
