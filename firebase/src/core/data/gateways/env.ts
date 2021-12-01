interface Credentials {
  git: {
    username: string;
    password: string;
  };
}

/** Exposes environment config variables. */
export class Env {
  readonly #config: Record<string, unknown>;

  constructor(config: Record<string, unknown>) {
    this.#config = config;
  }

  get isLocalDevelopment(): boolean {
    return process.env["FUNCTIONS_EMULATOR"] === "true" || process.env["ENVIRONMENT"] === "DEV";
  }

  get gitUsername(): string {
    const credentials = this.#config["credentials"] as Credentials;
    return credentials.git.username;
  }

  get gitPassword(): string {
    const credentials = this.#config["credentials"] as Credentials;
    return credentials.git.password;
  }
}
