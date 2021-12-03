import { ShellGateway } from "@data/gateways/shell-gateway";

/** Interfaces access to the project git repository information. */
export class GitRepository {
  readonly #shellGateway: ShellGateway;

  constructor(shellGateway: ShellGateway) {
    this.#shellGateway = shellGateway;
  }

  /** Returns the SHA hash from the last merge commit made in the current checkout branch. */
  async lastMergeCommitHash(): Promise<string> {
    return this.#shellGateway.run("git rev-list --min-parents=2 --max-count=1 HEAD");
  }

  /** Returns the SHA hash from the last commit made in the current checkout branch. */
  async lastCommitHash(): Promise<string> {
    return this.#shellGateway.run("git rev-parse HEAD");
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
