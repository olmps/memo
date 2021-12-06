import { StoredPublicCollection } from "#domain/models/collection";
import { FirestoreGateway } from "#data/gateways/firestore-gateway";
import { SchemaValidator } from "#data/schemas/schema-validator";

export class StoredCollectionsRepository {
  readonly #firestore: FirestoreGateway;
  readonly #schemaValidator: SchemaValidator;

  constructor(firestore: FirestoreGateway, schemaValidator: SchemaValidator) {
    this.#firestore = firestore;
    this.#schemaValidator = schemaValidator;
  }

  async setCollections(collections: StoredPublicCollection[]): Promise<void> {
    await this.#firestore.runTransaction(async () => {
      const sets = collections.map((collection) => {
        const rawCollection = (<unknown>collection) as Record<string, unknown>;
        this.#schemaValidator.validateObject("stored-public-collection", rawCollection);

        return this.#firestore.setDoc({
          id: collection.id,
          path: "collections",
          data: rawCollection,
        });
      });

      await Promise.all(sets);
    });
  }

  async deleteCollectionsByIds(collectionIds: string[]): Promise<void> {
    await this.#firestore.runTransaction(async () => {
      const deletions = collectionIds.map((id) =>
        this.#firestore.deleteDocRecursively({ id: id, path: "collections" })
      );
      await Promise.all(deletions);
    });
  }

  async getAllCollectionsByIds(collectionIds: string[]): Promise<StoredPublicCollection[]> {
    const fetches = collectionIds.map((id) => this.#firestore.getDoc({ id: id, path: "collections" }));
    const rawCollections = await Promise.all(fetches);
    return rawCollections
      .filter((collection) => collection != null)
      .map((collection) => this.#deserializeCollection(collection! as Record<string, unknown>));
  }

  #deserializeCollection(raw: Record<string, unknown>): StoredPublicCollection {
    this.#schemaValidator.validateObject("stored-public-collection", raw);
    const collection = (<unknown>raw) as StoredPublicCollection;

    return {
      id: collection.id,
      name: collection.name,
      description: collection.description,
      tags: collection.tags,
      category: collection.category,
      locale: collection.locale,
      contributors: collection.contributors,
      resources: collection.resources,
      memosAmount: collection.memosAmount,
      memosOrder: collection.memosOrder,
    };
  }
}
