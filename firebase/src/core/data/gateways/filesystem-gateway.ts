import * as fs from "fs";
import FilesystemError from "@faults/errors/filesystem-error";

/** Exposes common filesystem operations. */
export class FileSystemGateway {
  readonly #root = process.cwd();

  /**
   * Read all files in {@link dir}.
   *
   * @reject {FilesystemError} Something went wrong while reading the filesystem.
   * @fulfill {string[]} List of all files as raw strings.
   */
  async readDirFilesAsStrings(
    dir: string,
    { encoding }: { encoding: BufferEncoding } = { encoding: "utf-8" }
  ): Promise<string[]> {
    const processDir = `${this.#root}/${dir}`;
    try {
      const files = await fs.promises.readdir(processDir);
      const result = await Promise.all(
        files.map((file) => {
          return fs.promises.readFile(`${processDir}/${file}`, { encoding });
        })
      );

      return result;
    } catch (err) {
      return Promise.reject(
        new FilesystemError({ message: `Failed to read files in directory "${processDir}".`, origin: err })
      );
    }
  }

  /**
   * Read the file in {@link file}.
   *
   * @reject {FilesystemError} Something went wrong while reading the filesystem.
   * @fulfill {string} Read file.
   */
  async readFileAsString(
    file: string,
    { encoding }: { encoding: BufferEncoding } = { encoding: "utf-8" }
  ): Promise<string> {
    const processDir = `${this.#root}/${file}`;
    try {
      const file = await fs.promises.readFile(processDir, { encoding });
      return file;
    } catch (err) {
      return Promise.reject(new FilesystemError({ message: `Failed to read file "${processDir}".`, origin: err }));
    }
  }
}
