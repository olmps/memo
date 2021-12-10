import * as sinon from "sinon";
import * as assert from "assert";
import * as collection from "#domain/models/collection";
import * as memo from "#domain/models/memo";
import { LocalCollectionsRepository } from "#data/repositories/local-collections-repository";
import { StoredCollectionsRepository } from "#data/repositories/stored-collections-repository";
import { MemosRepository } from "#data/repositories/memos-repository";
import { GitRepository } from "#data/repositories/git-repository";
import createSinonStub from "#test/sinon-stub";
import { SyncCollectionsUseCase } from "#domain/use-cases/collections/sync-collections";
import { newRawLocalCollection, newRawMemo, newRawMemoContent } from "#test/core/data/schemas/collections-fakes";

describe("SyncCollectionsUseCase", () => {
  let sandbox: sinon.SinonSandbox;
  let localCollectionsRepoStub: sinon.SinonStubbedInstance<LocalCollectionsRepository>;
  let storedCollectionsRepoStub: sinon.SinonStubbedInstance<StoredCollectionsRepository>;
  let memosRepoStub: sinon.SinonStubbedInstance<MemosRepository>;
  let gitRepoStub: sinon.SinonStubbedInstance<GitRepository>;
  let syncCollectionsUseCase: SyncCollectionsUseCase;

  let validateLocalCollectionStub: sinon.SinonStub;
  let validateStoredCollectionStub: sinon.SinonStub;
  let validateMemoStub: sinon.SinonStub;

  before(() => {
    sandbox = sinon.createSandbox();

    const localCollections = (localCollectionsRepoStub = createSinonStub(LocalCollectionsRepository, sandbox));
    const storedCollections = (storedCollectionsRepoStub = createSinonStub(StoredCollectionsRepository, sandbox));
    const memosRepo = (memosRepoStub = createSinonStub(MemosRepository, sandbox));
    const gitRepo = (gitRepoStub = createSinonStub(GitRepository, sandbox));

    syncCollectionsUseCase = new SyncCollectionsUseCase(localCollections, storedCollections, memosRepo, gitRepo);
  });

  beforeEach(() => {
    validateLocalCollectionStub = sandbox.stub(collection, "validateLocalCollection");
    validateStoredCollectionStub = sandbox.stub(collection, "validateStoredCollection");
    validateMemoStub = sandbox.stub(memo, "validateMemo");

    validateLocalCollectionStub.resolves();
    validateStoredCollectionStub.resolves();
    validateMemoStub.resolves();

    gitRepoStub.lastCommitHash.resolves("lastCommitHash");
    gitRepoStub.lastMergeCommitHash.resolves("lastMergeCommitHash");
    gitRepoStub.gitDiff.resolves(
      "A firebase/collections/a.json\nM firebase/collections/b.json\nD firebase/collections/c.json\nR firebase/collections/d.json firebase/collections/e.json"
    );

    storedCollectionsRepoStub.deleteCollectionsByIds.resolves();
    storedCollectionsRepoStub.setCollections.resolves();

    memosRepoStub.getAllMemos.resolves([]);
    memosRepoStub.setMemos.resolves();
    memosRepoStub.removeMemosByIds.resolves();

    localCollectionsRepoStub.getAllCollectionsByIds.resolves([newRawLocalCollection()]);
  });

  afterEach(() => {
    sandbox.reset();

    validateLocalCollectionStub.restore();
    validateStoredCollectionStub.restore();
    validateMemoStub.restore();
  });

  // Simulates all possible failures during collections sync that must make the whole use-case fail.
  describe("Failures - ", () => {
    it("should fail when failing to retrieve last commit hash", async () => {
      const fakeError = Error("lastCommitHashMockedErrorMessage");

      gitRepoStub.lastCommitHash.rejects(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when failing to retrieve last merge commit hash", async () => {
      const fakeError = Error("lastMergeCommitHashMockedErrorMessage");

      gitRepoStub.lastMergeCommitHash.rejects(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when failing to retrieve git diff between two commits", async () => {
      const fakeError = Error("gitDiffMockedErrorMessage");

      gitRepoStub.gitDiff.rejects(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when failing to retrieve a set of collections by their ids", async () => {
      const fakeError = Error("getAllCollectionsByIdsMockedErrorMessage");

      localCollectionsRepoStub.getAllCollectionsByIds.rejects(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when failing to delete a set of collections by their ids", async () => {
      const fakeError = Error("deleteCollectionsByIdsMockedErrorMessage");

      storedCollectionsRepoStub.deleteCollectionsByIds.rejects(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when failing to update a set of collections", async () => {
      const fakeError = Error("setCollectionsMockedErrorMessage");

      storedCollectionsRepoStub.setCollections.rejects(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when failing to retrieve all memos from a given collection", async () => {
      const fakeError = Error("getAllMemosMockedErrorMessage");

      memosRepoStub.getAllMemos.rejects(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when failing to update a set of memos", async () => {
      const fakeError = Error("setMemosMockedErrorMessage");

      memosRepoStub.setMemos.rejects(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when failing to delete a set of memos", async () => {
      const fakeError = Error("removeMemosByIdsMockedErrorMessage");

      memosRepoStub.removeMemosByIds.rejects(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when failing to validate local collection entity", async () => {
      const fakeError = Error("validateLocalCollectionMockedErrorMessage");

      validateLocalCollectionStub.throws(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when to validate stored collection entity", async () => {
      const fakeError = Error("validateStoredCollectionMockedErrorMessage");

      validateStoredCollectionStub.throws(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });

    it("should fail when to validate memo entity", async () => {
      const fakeError = Error("validateMemoMockedErrorMessage");

      validateMemoStub.throws(fakeError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), fakeError);
    });
  });

  // Simulates collections operations (additions, removals, updates and renames).
  describe("Collections Operations", () => {
    it("should save all added collections", async () => {
      const fakeCollections: any[] = [
        { id: "a", foo: "bar", memos: [], memosAmount: 0, memosOrder: [] },
        { id: "b", foo: "bar", memos: [], memosAmount: 0, memosOrder: [] },
      ];
      const fakeCollectionsIds = fakeCollections.map((collection) => collection.id);
      const gitDiff = fakeCollectionsIds.map((id) => `A firebase/collections/${id}.json\n`).join(" ");
      gitRepoStub.gitDiff.resolves(gitDiff);
      localCollectionsRepoStub.getAllCollectionsByIds.withArgs(fakeCollectionsIds).resolves(fakeCollections);

      await syncCollectionsUseCase.run();

      assert.ok(storedCollectionsRepoStub.setCollections.calledOnceWithExactly(fakeCollections));
    });

    it("should save all updated collections", async () => {
      const fakeCollections: any[] = [
        { id: "a", foo: "bar", memos: [], memosAmount: 0, memosOrder: [] },
        { id: "b", foo: "bar", memos: [], memosAmount: 0, memosOrder: [] },
      ];
      const fakeCollectionsIds = fakeCollections.map((collection) => collection.id);
      const gitDiff = fakeCollectionsIds.map((id) => `M firebase/collections/${id}.json\n`).join(" ");
      gitRepoStub.gitDiff.resolves(gitDiff);
      localCollectionsRepoStub.getAllCollectionsByIds.withArgs(fakeCollectionsIds).resolves(fakeCollections);

      await syncCollectionsUseCase.run();

      assert.ok(storedCollectionsRepoStub.setCollections.calledOnceWithExactly(fakeCollections));
    });

    it("should remove all deleted collections", async () => {
      const fakeCollectionsIds = ["a", "b"];
      const gitDiff = fakeCollectionsIds.map((id) => `D firebase/collections/${id}.json\n`).join(" ");
      gitRepoStub.gitDiff.resolves(gitDiff);

      await syncCollectionsUseCase.run();

      assert.ok(storedCollectionsRepoStub.deleteCollectionsByIds.calledOnceWithExactly(fakeCollectionsIds));
    });

    it("should remove previous name and add new name collections", async () => {
      const fakeAddedCollectionId = "b";
      const fakeRemovedCollectionId = "a";
      const fakeAddedCollections: any[] = [
        { id: fakeAddedCollectionId, foo: "bar", memos: [], memosAmount: 0, memosOrder: [] },
      ];

      gitRepoStub.gitDiff.resolves(
        `R firebase/collections/${fakeRemovedCollectionId}.json firebase/collections/${fakeAddedCollectionId}.json`
      );
      localCollectionsRepoStub.getAllCollectionsByIds.withArgs([fakeAddedCollectionId]).resolves(fakeAddedCollections);

      await syncCollectionsUseCase.run();

      assert.ok(storedCollectionsRepoStub.setCollections.calledOnceWithExactly(fakeAddedCollections));
      assert.ok(storedCollectionsRepoStub.deleteCollectionsByIds.calledOnceWithExactly([fakeRemovedCollectionId]));
    });
  });

  // Simulates memos entity modifications.
  describe("Memos Operations", () => {
    const fakeMemo = newRawMemo({ id: "a" });
    const secondFakeMemo = newRawMemo({ id: "b" });
    const fakeMemos = [fakeMemo, secondFakeMemo];

    it("should save memos from an added collection", async () => {
      const fakeCollection: any = { id: "a", foo: "bar", memos: [fakeMemo] };
      const expectedAddedCollections: any[] = [{ ...fakeCollection, memosAmount: 1, memosOrder: [fakeMemo.id] }];
      const expectedAddedMemos = new Map<string, memo.Memo[]>([[fakeCollection.id, [fakeMemo]]]);

      gitRepoStub.gitDiff.resolves(`A firebase/collections/${fakeCollection.id}.json\n`);
      localCollectionsRepoStub.getAllCollectionsByIds.withArgs([fakeCollection.id]).resolves([fakeCollection]);
      memosRepoStub.getAllMemos.resolves([]);

      await syncCollectionsUseCase.run();
      const addedCollections = storedCollectionsRepoStub.setCollections.lastCall
        .lastArg as collection.StoredPublicCollection[];
      const removedMemos = memosRepoStub.removeMemosByIds.lastCall.lastArg as Map<string, string>;
      const updatedMemos = memosRepoStub.setMemos.lastCall.lastArg as Map<string, memo.Memo[]>;

      assert.deepStrictEqual(addedCollections, expectedAddedCollections);
      assert.deepStrictEqual(removedMemos, new Map<string, string>());
      assert.deepStrictEqual(updatedMemos, expectedAddedMemos);
    });

    it("should save new memos from an updated collection", async () => {
      const fakeNewMemo = newRawMemo({ id: "c" });
      const fakeCollection: any = { id: "a", foo: "bar", memos: [...fakeMemos, fakeNewMemo] };
      const fakeMemosIds = fakeCollection.memos.map((memo: any) => memo.id);
      const expectedAddedCollections: any[] = [{ ...fakeCollection, memosAmount: 3, memosOrder: fakeMemosIds }];
      const expectedAddedMemos = new Map<string, memo.Memo[]>([[fakeCollection.id, [fakeNewMemo]]]);

      gitRepoStub.gitDiff.resolves(`M firebase/collections/${fakeCollection.id}.json\n`);
      localCollectionsRepoStub.getAllCollectionsByIds.withArgs([fakeCollection.id]).resolves([fakeCollection]);
      memosRepoStub.getAllMemos.resolves(fakeMemos);

      await syncCollectionsUseCase.run();
      const addedCollections = storedCollectionsRepoStub.setCollections.lastCall
        .lastArg as collection.StoredPublicCollection[];
      const removedMemos = memosRepoStub.removeMemosByIds.lastCall.lastArg as Map<string, string>;
      const updatedMemos = memosRepoStub.setMemos.lastCall.lastArg as Map<string, memo.Memo[]>;

      assert.deepStrictEqual(addedCollections, expectedAddedCollections);
      assert.deepStrictEqual(removedMemos, new Map<string, string>());
      assert.deepStrictEqual(updatedMemos, expectedAddedMemos);
    });

    it("should update modified memos from an existing collection", async () => {
      const fakeUpdatedMemo = newRawMemo({ id: "b", question: newRawMemoContent({ insert: "updated" }) });
      const fakeCollection: any = { id: "a", foo: "bar", memos: [fakeMemo, fakeUpdatedMemo] };
      const fakeMemosIds = fakeCollection.memos.map((memo: any) => memo.id);
      const expectedAddedCollections: any[] = [{ ...fakeCollection, memosAmount: 2, memosOrder: fakeMemosIds }];
      const expectedAddedMemos = new Map<string, memo.Memo[]>([[fakeCollection.id, [fakeUpdatedMemo]]]);

      gitRepoStub.gitDiff.resolves(`M firebase/collections/${fakeCollection.id}.json\n`);
      localCollectionsRepoStub.getAllCollectionsByIds.withArgs([fakeCollection.id]).resolves([fakeCollection]);
      memosRepoStub.getAllMemos.resolves([fakeMemo, secondFakeMemo]);

      await syncCollectionsUseCase.run();
      const addedCollections = storedCollectionsRepoStub.setCollections.lastCall
        .lastArg as collection.StoredPublicCollection[];
      const removedMemos = memosRepoStub.removeMemosByIds.lastCall.lastArg as Map<string, string>;
      const updatedMemos = memosRepoStub.setMemos.lastCall.lastArg as Map<string, memo.Memo[]>;

      assert.deepStrictEqual(addedCollections, expectedAddedCollections);
      assert.deepStrictEqual(removedMemos, new Map<string, string>());
      assert.deepStrictEqual(updatedMemos, expectedAddedMemos);
    });

    it("should remove a subset of memos from an existing collection", async () => {
      const removedMemoId = secondFakeMemo.id;
      const fakeCollection: any = { id: "a", foo: "bar", memos: [fakeMemo] };
      const fakeMemosIds = fakeCollection.memos.map((memo: any) => memo.id);
      const expectedAddedCollections: any[] = [{ ...fakeCollection, memosAmount: 1, memosOrder: fakeMemosIds }];
      const expectedRemovedMemos = new Map<string, string[]>([[fakeCollection.id, [removedMemoId]]]);

      gitRepoStub.gitDiff.resolves(`M firebase/collections/${fakeCollection.id}.json\n`);
      localCollectionsRepoStub.getAllCollectionsByIds.withArgs([fakeCollection.id]).resolves([fakeCollection]);
      memosRepoStub.getAllMemos.resolves([fakeMemo, secondFakeMemo]);

      await syncCollectionsUseCase.run();
      const addedCollections = storedCollectionsRepoStub.setCollections.lastCall
        .lastArg as collection.StoredPublicCollection[];
      const removedMemos = memosRepoStub.removeMemosByIds.lastCall.lastArg as Map<string, string>;
      const updatedMemos = memosRepoStub.setMemos.lastCall.lastArg as Map<string, memo.Memo[]>;

      assert.deepStrictEqual(addedCollections, expectedAddedCollections);
      assert.deepStrictEqual(removedMemos, expectedRemovedMemos);
      assert.deepStrictEqual(updatedMemos, new Map<string, memo.Memo[]>());
    });

    it("should remove all memos from a removed collection", async () => {
      const fakeCollection: any = { id: "a", foo: "bar", memos: [fakeMemo, secondFakeMemo] };

      gitRepoStub.gitDiff.resolves(`D firebase/collections/${fakeCollection.id}.json\n`);
      localCollectionsRepoStub.getAllCollectionsByIds.withArgs([fakeCollection.id]).resolves([]);
      memosRepoStub.getAllMemos.resolves([fakeMemo, secondFakeMemo]);

      await syncCollectionsUseCase.run();
      const removedCollections = storedCollectionsRepoStub.deleteCollectionsByIds.lastCall.lastArg as string[];

      assert.deepStrictEqual(removedCollections, [fakeCollection.id]);
      assert.ok(storedCollectionsRepoStub.setCollections.notCalled);
      // removeMemosByIds shouldn't be called because the memos of a deleted collection are deleted recursively when
      // deleteCollectionsByIds is invoked.
      assert.ok(memosRepoStub.removeMemosByIds.notCalled);
      assert.ok(memosRepoStub.setMemos.notCalled);
    });
  });
});
