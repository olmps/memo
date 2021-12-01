import { LocalPublicCollection } from "#domain/models/collection";
import { FileSystemGateway } from "#data/gateways/filesystem-gateway";
import { SchemaValidator } from "#data/schemas/schema-validator";

export class LocalCollectionsRepository {
  readonly #fs: FileSystemGateway;
  readonly #schemaValidator: SchemaValidator;
  readonly #collectionsDir: string;

  constructor(fs: FileSystemGateway, schemaValidator: SchemaValidator, collectionsDir: string) {
    this.#fs = fs;
    this.#schemaValidator = schemaValidator;
    this.#collectionsDir = collectionsDir;
  }

  async getAllCollectionsByIds(collectionIds: string[]): Promise<LocalPublicCollection[]> {
    const files = collectionIds.map((id) => this.#fs.readFileAsString(`${this.#collectionsDir}/${id}.json`));
    const rawCollections = await Promise.all(files);
    const jsonCollections: Record<string, unknown>[] = rawCollections.map((collection) => JSON.parse(collection));
    return jsonCollections.map((collection) => this.#deserializeCollection(collection));
  }

  #deserializeCollection(raw: Record<string, unknown>): LocalPublicCollection {
    this.#schemaValidator.validateObject("local-public-collection", raw);
    const collection = (<unknown>raw) as LocalPublicCollection;

    return {
      id: collection.id,
      name: collection.name,
      description: collection.description,
      tags: collection.tags,
      category: collection.category,
      locale: collection.locale,
      contributors: collection.contributors,
      resources: collection.resources,
      memos: collection.memos,
    };
  }
}
