import { LocalCollectionsRepository } from "#data/repositories/local-collections-repository";
import { MemosRepository } from "#data/repositories/memos-repository";
import { StoredCollectionsRepository } from "#data/repositories/stored-collections-repository";
import { addToMap } from "#utils/add-to-map";
import { objectsEqual } from "#utils/deep-equals";
import {
  LocalPublicCollection,
  StoredPublicCollection,
  validateLocalCollection,
  validateStoredCollection,
} from "#domain/models/collection";
import { Memo, validateLocalMemo } from "#domain/models/memo";
import { GitRepository } from "#data/repositories/git-repository";

type CollectionMemosDiff = [Memo[], string[]];

interface UpdatedCollections {
  /** Identifiers from all collections that were added since last update. */
  added: string[];
  /** Identifiers from all collections that were updated since last update. */
  updated: string[];
  /** Identifiers from all collections that were removed since last update. */
  removed: string[];
}

export class SyncCollectionsUseCase {
  readonly #localCollectionsRepo: LocalCollectionsRepository;
  readonly #storedCollectionsRepo: StoredCollectionsRepository;
  readonly #memosRepo: MemosRepository;
  readonly #gitRepo: GitRepository;

  constructor(
    localCollectionsRepo: LocalCollectionsRepository,
    storedCollectionsRepo: StoredCollectionsRepository,
    memosRepo: MemosRepository,
    gitRepo: GitRepository
  ) {
    this.#localCollectionsRepo = localCollectionsRepo;
    this.#storedCollectionsRepo = storedCollectionsRepo;
    this.#memosRepo = memosRepo;
    this.#gitRepo = gitRepo;
  }

  /**
   * Synchronize the expected state of collections (and its memos) to what we have stored.
   *
   * Local collections are considered our source of truth (what we expect), meaning that any difference between what's
   * stored (what we have), should be respectively added, updated or removed.
   *
   * Communicates with Github to fetch a list of ids that were added/updated (no matter which operation, a set
   * will be performed) and those that were removed.
   *
   * While it may not be the best performant strategy, this execution should be idempotent.
   */
  async run(): Promise<void> {
    const collectionsDiff = await this.#diffCollections();
    const operations: Promise<void>[] = [];

    const addedOrUpdated = collectionsDiff.added.concat(collectionsDiff.updated);
    if (addedOrUpdated.length > 0) {
      const localCollections = await this.#localCollectionsRepo.getAllCollectionsByIds(addedOrUpdated);
      operations.push(this.#syncCollections(localCollections));
    }

    if (collectionsDiff.removed.length > 0) {
      operations.push(this.#storedCollectionsRepo.deleteCollectionsByIds(collectionsDiff.removed));
    }

    await Promise.all(operations);
  }

  /** Update all {@link localCollections} and its respective memos. */
  async #syncCollections(localCollections: LocalPublicCollection[]): Promise<void> {
    const updatableMemos = new Map<string, Memo[]>();
    const deletableMemosIds = new Map<string, string[]>();

    const updateableCollections: StoredPublicCollection[] = [];

    for (const localCollection of localCollections) {
      validateLocalCollection(localCollection);

      //
      // Adding/Updating collection
      //
      const memosOrder = localCollection.memos.map(({ id }) => id);
      const storableCollection = {
        ...localCollection,
        memosAmount: memosOrder.length,
        memosOrder: memosOrder,
      };
      validateStoredCollection(storableCollection);
      updateableCollections.push(storableCollection);

      //
      // Adding/Updating collection memos
      //
      // TODO(matuella): all memos, ideally, should be fetched all at once, and not each individually per collection.
      const memosDiff = await this.#diffMemos(localCollection.id, localCollection.memos);
      if (memosDiff[0].length > 0) {
        addToMap(updatableMemos, localCollection.id, ...memosDiff[0]);
      }

      if (memosDiff[1].length > 0) {
        addToMap(deletableMemosIds, localCollection.id, ...memosDiff[1]);
      }
    }

    await Promise.all([
      this.#storedCollectionsRepo.setCollections(updateableCollections),
      this.#memosRepo.setMemos(updatableMemos),
      this.#memosRepo.removeMemosByIds(deletableMemosIds),
    ]);
  }

  /**
   * Output the difference between the expected and stored memos.
   *
   * @param collectionId The parent collection id.
   * @param localMemos The local (expected) memos to be matched against the stored (current) ones.
   * @returns A {@link CollectionMemosDiff} tuple that represents a list of updatable memos (which must be added or
   * updated) and a list of removable memos, mapped by their ids.
   */
  async #diffMemos(collectionId: string, localMemos: Memo[]): Promise<CollectionMemosDiff> {
    const deletableMemosIds: string[] = [];
    const updateableMemos: Memo[] = [];

    const storedMemos = await this.#memosRepo.getAllMemos(collectionId);
    for (const localMemo of localMemos) {
      validateLocalMemo(localMemo);

      const storedMemo = storedMemos.find((storedMemo) => storedMemo.id === localMemo.id);
      if (!objectsEqual(storedMemo, localMemo)) {
        updateableMemos.push(localMemo);
      }
    }

    for (const storedMemo of storedMemos) {
      const memoStillExists = localMemos.some((memo) => memo.id === storedMemo.id);
      if (!memoStillExists) {
        deletableMemosIds.push(storedMemo.id);
      }
    }

    return [updateableMemos, deletableMemosIds];
  }

  /**
   * Returns the changed (added, updated and removed) collections ids.
   *
   * The collections diff is made by using `git ...` shell commands, so make sure to run the current use-case in the
   * expected git HEAD.
   */
  async #diffCollections(): Promise<UpdatedCollections> {
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

    const addedCollections = changedCollections.filter((collectionFile) => collectionFile.trim().startsWith("A"));
    const updatedCollections = changedCollections.filter((collectionFile) => collectionFile.trim().startsWith("M"));
    const removedCollections = changedCollections.filter((collectionFile) => collectionFile.trim().startsWith("D"));
    const renamedFiles = changedCollections.filter((collectionFile) => collectionFile.trim().startsWith("R"));

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
