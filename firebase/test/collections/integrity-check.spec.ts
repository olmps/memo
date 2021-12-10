import * as assert from "assert";
import * as fs from "fs";
import Provider from "#presentation/provider";

describe("Collections Integrity Check", () => {
  let localCollectionsPaths: string[];
  let rawLocalCollections: any[];

  before(async () => {
    localCollectionsPaths = await fs.promises.readdir(`${process.cwd()}/collections`);

    const fsGateway = Provider.instance.fileSystemGateway;
    const localCollections = await fsGateway.readDirFilesAsStrings("./collections");
    rawLocalCollections = localCollections.map((collection) => JSON.parse(collection));
  });

  it("should maintain naming/id consistency", () => {
    for (let index = 0; index < localCollectionsPaths.length; index++) {
      const collectionId: string = rawLocalCollections[index]["id"];
      const fullCollectionPath = localCollectionsPaths[index]!;
      assert.ok(
        fullCollectionPath.includes(`${collectionId}.json`),
        `Collection had id "${collectionId}" but file path "${fullCollectionPath}"`
      );
    }
  });

  it("should have unique ids amongst themselves", () => {
    const collectionIds: string[] = [];
    rawLocalCollections.forEach((collection) => {
      const collectionId: string = collection["id"];
      assert.ok(!collectionIds.includes(collectionId), `Duplicate collection id "${collectionId}"`);
      collectionIds.push(collectionId);
    });
  });

  it("should have unique memo ids amongst themselves", () => {
    const memosIds: string[] = [];
    for (const collection of rawLocalCollections) {
      const memos: any[] = collection["memos"];
      memos.forEach((rawMemo) => {
        const memoUniqueId: string = rawMemo["id"] as string;
        assert.ok(
          !memosIds.includes(memoUniqueId),
          `Duplicate memo id "${memoUniqueId}" in collection "${collection}"`
        );
        memosIds.push(memoUniqueId);
      });
    }
  });

  it("should have expected JSON structure", () => {
    const schemaValidator = Provider.instance.schemaValidator;

    for (const rawCollection of rawLocalCollections) {
      assert.doesNotThrow(() => schemaValidator.validateObject("local-public-collection", rawCollection));
    }
  });
});
