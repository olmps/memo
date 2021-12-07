/** Exposes environment config variables. */
export class EnvGateway {
  /** Returns `true` if running in local environment, i.e, under Firebase Emulators. */
  get isLocalDevelopment(): boolean {
    return process.env["FUNCTIONS_EMULATOR"] === "true";
  }
}
