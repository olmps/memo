import { CollectionsDiffUseCase } from "@domain/use-cases/collections/collections-diff";
import Provider from "src/core/presentation/provider";

async function runScript(): Promise<void> {
  try {
    const collectionsUpdate = await new CollectionsDiffUseCase(Provider.instance.gitRepository).run();

    console.log(JSON.stringify(collectionsUpdate));
  } catch (error) {
    console.dir(error, { depth: null, colors: true });
  }
}

runScript().finally(() => {
  process.exit(0);
});
