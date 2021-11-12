import { SyncCollectionsUseCase } from "@domain/use-cases/collections/sync-collections";
import Provider from "src/core/presentation/provider";

// 1. Verificar se vale a pena fazer os "// TODO" pendentes.
// 2. Verificar se as rules estão ainda funcionando, o que mudou da modelagem de hoje.
// 3. Finalizar o script (conectar com o "env"+actions, passar args).
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

async function runScript(): Promise<void> {
  // TODO: Get these as parameters from the running script (env?)
  const addedOrUpdated = ["test"];
  const removed = undefined;

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
