type ConfigKeys = "credentials";
type Config = Record<ConfigKeys, unknown>;

type CredentialsKeys = "project_id" | "client_email" | "private_key";
type Credentials = Record<CredentialsKeys, string>;

interface FirebaseServiceAccountMetadata {
  projectId: string;
  clientEmail: string;
  privateKey: string;
}

/** Exposes environment config variables. */
export class EnvGateway {
  readonly #config: Config;

  constructor(config: Record<string, unknown>) {
    this.#config = config as Config;
  }

  /** Returns `true` if running in local environment, i.e, under Firebase Emulators. */
  get isLocalDevelopment(): boolean {
    return process.env["FUNCTIONS_EMULATOR"] === "true" || process.env["ENVIRONMENT"] === "DEV";
  }

  get firebaseServiceAccount(): FirebaseServiceAccountMetadata {
    const credentialsConfig = this.#config["credentials"] as Credentials;
    const projectId = credentialsConfig["project_id"];
    const clientEmail = credentialsConfig["client_email"];
    const privateKey = credentialsConfig["private_key"];

    return {
      projectId,
      clientEmail,
      privateKey,
    };
  }
}
