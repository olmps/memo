class Dummy {
  constructor() {
    this.#value = "dummy";
  }

  readonly #value: string;

  get value(): string {
    return this.#value;
  }
}

export const dummy = new Dummy();
