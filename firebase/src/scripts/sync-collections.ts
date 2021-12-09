import { SyncCollectionsUseCase } from "#domain/use-cases/collections/sync-collections";
import Provider from "#presentation/provider";

async function runScript(): Promise<void> {
  try {
    await new SyncCollectionsUseCase(
      Provider.instance.localCollectionsRepository("./collections"),
      Provider.instance.storedCollectionsRepository,
      Provider.instance.memosRepository,
      Provider.instance.gitRepository
    ).run();
  } catch (error) {
    console.dir(error, { depth: null, colors: true });
  }
}

runScript().finally(() => {
  process.exit(0);
});
