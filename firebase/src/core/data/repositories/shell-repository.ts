import { ShellGateway } from "@data/gateways/shell-gateway";

export class ShellRepository {
  readonly #shellGateway: ShellGateway;

  constructor(shellGateway: ShellGateway) {
    this.#shellGateway = shellGateway;
  }

  /** Runs `git diff` shell command between `base` and `head` commit hashes. */
  async gitDiff(base: string, head: string, options?: { nameStatus: boolean }): Promise<string> {
    let command = "git diff";
    if (options?.nameStatus) {
      command += " --name-status";
    }

    command += ` ${base} ${head}`;

    return this.#shellGateway.run(command);
  }
}
