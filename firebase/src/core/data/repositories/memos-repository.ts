import { Memo } from "#domain/models/memo";
import { FirestoreGateway } from "#data/gateways/firestore-gateway";
import { SchemaValidator } from "#data/schemas/schema-validator";

export class MemosRepository {
  readonly #firestore: FirestoreGateway;
  readonly #schemaValidator: SchemaValidator;

  constructor(firestore: FirestoreGateway, schemaValidator: SchemaValidator) {
    this.#firestore = firestore;
    this.#schemaValidator = schemaValidator;
  }

  async setMemos(memosPerCollection: Map<string, Memo[]>): Promise<void> {
    await this.#firestore.runTransaction(async () => {
      const sets: Promise<void>[] = [];
      for (const [collectionId, memos] of memosPerCollection.entries()) {
        const memosSets = memos.map((memo) => {
          const serializedMemo = this.#deserializeMemo((<unknown>memo) as Record<string, unknown>);

          return this.#firestore.setDoc({
            id: memo.id,
            path: `collections/${collectionId}/memos`,
            data: (<unknown>serializedMemo) as Record<string, unknown>,
          });
        });

        sets.push(...memosSets);
      }

      await Promise.all(sets);
    });
  }

  async removeMemosByIds(memosIdsPerCollection: Map<string, string[]>): Promise<void> {
    this.#firestore.runTransaction(async () => {
      const deletions: Promise<void>[] = [];
      for (const [collectionId, memos] of memosIdsPerCollection.entries()) {
        const memosDeletions = memos.map((memoId) =>
          this.#firestore.deleteDoc({
            id: memoId,
            path: `collections/${collectionId}/memos`,
          })
        );

        deletions.push(...memosDeletions);
      }

      await Promise.all(deletions);
    });
  }

  async getAllMemos(collectionId: string): Promise<Memo[]> {
    const rawMemos = await this.#firestore.getCollection(`collections/${collectionId}/memos`);
    return rawMemos.map((memo) => this.#deserializeMemo(memo));
  }

  #deserializeMemo(raw: Record<string, unknown>): Memo {
    this.#schemaValidator.validateObject("memo", raw);
    const memo = (<unknown>raw) as Memo;

    return {
      id: memo.id,
      question: memo.question,
      answer: memo.answer,
    };
  }
}
