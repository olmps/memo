import { GitRepository } from "@data/repositories/git-repository";

interface UpdatedCollections {
  /** Identifiers from all collections that were added since last update. */
  added: string[];
  /** Identifiers from all collections that were updated since last update. */
  updated: string[];
  /** Identifiers from all collections that were removed since last update. */
  removed: string[];
}

export class CollectionsDiffUseCase {
  readonly #gitRepo: GitRepository;

  constructor(gitRepo: GitRepository) {
    this.#gitRepo = gitRepo;
  }

  /**
   * Returns the changed (added, updated and removed) collections ids.
   *
   * The collections diff is made by using `git ...` shell commands, so make sure to run the current use-case in the
   * expected git HEAD.
   */
  async run(): Promise<UpdatedCollections> {
    const currentCommitHash = await this.#gitRepo.lastCommitHash();
    const lastMergeCommitHash = await this.#gitRepo.lastMergeCommitHash();

    // Uses `git diff` to get all updated files between both hashes and their status (added, modified, deleted or
    // renamed).
    const gitDiff = await this.#gitRepo.gitDiff(lastMergeCommitHash.trim(), currentCommitHash.trim(), {
      nameStatus: true,
    });
    const changedFiles: string[] = gitDiff.split("\n");

    // Filter by the files under `firebase/collections` directory.
    const changedCollections = changedFiles.filter((changedFile) => changedFile.includes("firebase/collections"));

    const addedCollections = changedCollections.filter((collectionFile) => collectionFile.startsWith("A"));
    const updatedCollections = changedCollections.filter((collectionFile) => collectionFile.startsWith("M"));
    const removedCollections = changedCollections.filter((collectionFile) => collectionFile.startsWith("D"));
    const renamedFiles = changedCollections.filter((collectionFile) => collectionFile.startsWith("R"));

    const addedCollectionsIds = addedCollections.map((collectionPath) =>
      collectionPath.substring(collectionPath.lastIndexOf("/") + 1, collectionPath.lastIndexOf(".json"))
    );
    const updatedCollectionsIds = updatedCollections.map((collectionPath) =>
      collectionPath.substring(collectionPath.lastIndexOf("/") + 1, collectionPath.lastIndexOf(".json"))
    );
    const removedCollectionsIds = removedCollections.map((collectionPath) =>
      collectionPath.substring(collectionPath.lastIndexOf("/") + 1, collectionPath.lastIndexOf(".json"))
    );

    // Regex that matches a name between `/` and `.json` bounds. Uses `g` global flag to match all occurrences instead
    // just the first one.
    const fileNameRegex = new RegExp(/[a-zA-Z0-9-+]+?(?=.json)/, "g");

    // Iterates through the renamed files adding the old collection file name to `removedCollectionsIds` and the new
    // name to `addedCollectionsIds`.
    for (const renamed of renamedFiles) {
      const removedFile = fileNameRegex.exec(renamed)![0]!;
      const addedFile = fileNameRegex.exec(renamed)![0]!;
      addedCollectionsIds.push(addedFile);
      removedCollectionsIds.push(removedFile);
    }

    return {
      added: addedCollectionsIds,
      updated: updatedCollectionsIds,
      removed: removedCollectionsIds,
    };
  }
}
