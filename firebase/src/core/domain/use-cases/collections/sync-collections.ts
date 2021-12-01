import { LocalCollectionsRepository } from "@data/repositories/local-collections-repository";
import { MemosRepository } from "@data/repositories/memos-repository";
import { StoredCollectionsRepository } from "@data/repositories/stored-collections-repository";
import { addToMap } from "@utils/add-to-map";
import { objectsEqual } from "@utils/deep-equals";
import {
  LocalPublicCollection,
  StoredPublicCollection,
  validateLocalCollection,
  validateStoredCollection,
} from "@domain/models/collection";
import { Memo, validateMemo } from "@domain/models/memo";

type CollectionMemosDiff = [Memo[], string[]];

export class SyncCollectionsUseCase {
  readonly #localCollectionsRepo: LocalCollectionsRepository;
  readonly #storedCollectionsRepo: StoredCollectionsRepository;
  readonly #memosRepo: MemosRepository;

  constructor(
    localCollectionsRepo: LocalCollectionsRepository,
    storedCollectionsRepo: StoredCollectionsRepository,
    memosRepo: MemosRepository
  ) {
    this.#localCollectionsRepo = localCollectionsRepo;
    this.#storedCollectionsRepo = storedCollectionsRepo;
    this.#memosRepo = memosRepo;
  }

  /**
   * Synchronize the expected state of collections (and its memos) to what we have stored.
   *
   * Local collections are considered our source of truth (what we expect), meaning that any difference between what's
   * stored (what we have), should be respectively added, updated or removed.
   *
   * The argument must specify a list of ids that were {@link addedOrUpdated} (no matter which operation, a set will be
   * performed) and those that were {@link removed}.
   *
   * While it may not be the best performant strategy, this execution should be idempotent.
   */
  async run({ addedOrUpdated, removed }: { addedOrUpdated?: string[]; removed?: string[] }): Promise<void> {
    const operations: Promise<void>[] = [];
    if (addedOrUpdated) {
      const localCollections = await this.#localCollectionsRepo.getAllCollectionsByIds(addedOrUpdated);
      operations.push(this.#syncCollections(localCollections));
    }

    if (removed) {
      operations.push(this.#storedCollectionsRepo.deleteCollectionsByIds(removed));
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
      validateMemo(localMemo);

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
}