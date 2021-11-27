import { SyncCollectionsUseCase } from "@domain/use-cases/collections/sync-collections";
import Provider from "src/core/presentation/provider";

// 1. Verificar se vale a pena fazer os "// TODO" pendentes.
// 4. Testes:
//  - Provider.
//  - schemas (/schemas/*).
//  - validators (/models/*).
//  - repositórios.
//  - gateways -> readFileAsString.
//  - gateways -> deleteDocRecursively; setDoc.
//  - utils (utils/*).
//  - domain/use-cases.
//  - scripts/sync-collections.

interface UpdatedCollections {
  /** Identifiers from all collections that were added since last release. */
  added: string[];
  /** Identifiers from all collections that were updated since last release. */
  updated: string[];
  /** Identifiers from all collections that were removed since last release. */
  removed: string[];
}

async function runScript(): Promise<void> {
  const collectionsDiff = process.env["COLLECTIONS_DIFF"]!;
  const parsedCollectionIds: UpdatedCollections = JSON.parse(collectionsDiff);

  const addedOrUpdated = parsedCollectionIds.added.concat(parsedCollectionIds.updated);
  const removed = parsedCollectionIds.removed;

  try {
    await new SyncCollectionsUseCase(
      Provider.instance.localCollectionsRepository("./collections"),
      Provider.instance.storedCollectionsRepository,
      Provider.instance.memosRepository
    ).run({ addedOrUpdated, removed });
  } catch (error) {
    console.dir(error, { depth: null, colors: true });
  }
}

runScript().finally(() => {
  process.exit(0);
});
