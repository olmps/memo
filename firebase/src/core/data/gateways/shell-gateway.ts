import ShellError from "@faults/errors/shell-error";
import { exec } from "child_process";

/** Exposes access to perform shell operations. */
export class ShellGateway {
  /** Runs {@link command} in shell and returns an UTF-8 decoded string. */
  async run(command: string): Promise<string> {
    return new Promise((resolve, reject) => {
      exec(command, (error, stdout, stderr) => {
        if (error) {
          reject(new ShellError({ message: `Failed to run ${command}`, origin: error }));
        } else if (stderr) {
          reject(new ShellError({ message: `Failed to run ${command}`, origin: stderr }));
        } else {
          resolve(stdout);
        }
      });
    });
  }
}
