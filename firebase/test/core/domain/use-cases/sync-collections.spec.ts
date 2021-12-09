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
import { newRawLocalCollection } from "#test/core/data/schemas/collections-fakes";

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
    it("should fail when GitRepository.lastCommitHash rejects", async () => {
      const mockError = Error("lastCommitHashMockedErrorMessage");

      gitRepoStub.lastCommitHash.rejects(mockError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), mockError);
    });

    it("should fail when GitRepository.lastMergeCommitHash rejects", async () => {
      const mockError = Error("lastMergeCommitHashMockedErrorMessage");

      gitRepoStub.lastMergeCommitHash.rejects(mockError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), mockError);
    });

    it("should fail when GitRepository.gitDiff rejects", async () => {
      const mockError = Error("gitDiffMockedErrorMessage");

      gitRepoStub.gitDiff.rejects(mockError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), mockError);
    });

    it("should fail when LocalCollectionsRepository.getAllCollectionsByIds rejects", async () => {
      const mockError = Error("getAllCollectionsByIdsMockedErrorMessage");

      localCollectionsRepoStub.getAllCollectionsByIds.rejects(mockError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), mockError);
    });

    it("should fail when StoredCollectionsRepository.deleteCollectionsByIds rejects", async () => {
      const mockError = Error("deleteCollectionsByIdsMockedErrorMessage");

      storedCollectionsRepoStub.deleteCollectionsByIds.rejects(mockError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), mockError);
    });

    it("should fail when validateLocalCollection rejects", async () => {
      const mockError = Error("validateLocalCollectionMockedErrorMessage");

      validateLocalCollectionStub.throws(mockError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), mockError);
    });

    it("should fail when validateStoredCollection rejects", async () => {
      const mockError = Error("validateStoredCollectionMockedErrorMessage");

      validateStoredCollectionStub.throws(mockError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), mockError);
    });

    it("should fail when validateMemo rejects", async () => {
      const mockError = Error("validateMemoMockedErrorMessage");

      validateMemoStub.throws(mockError);

      await assert.rejects(async () => await syncCollectionsUseCase.run(), mockError);
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
    it("should update collections with memos metadata", async () => {
      const fakeMemoId = "memoId";
      const fakeMemo = { id: fakeMemoId, foo: "bar" };
      const fakeFirstAddedCollection = { id: "a", foo: "bar", memos: [fakeMemo] };
      const fakeSecondAddedCollection = { id: "b", foo: "bar", memos: [] };
      const fakeAddedCollections: any[] = [fakeFirstAddedCollection, fakeSecondAddedCollection];
      const expectedAddedCollections: any[] = [
        { ...fakeFirstAddedCollection, memosAmount: 1, memosOrder: [fakeMemoId] },
        { ...fakeSecondAddedCollection, memosAmount: 0, memosOrder: [] },
      ];

      const fakeAddedCollectionsIds = fakeAddedCollections.map((collection) => collection.id);
      const gitDiff = fakeAddedCollectionsIds.map((id) => `A firebase/collections/${id}.json\n`).join(" ");
      gitRepoStub.gitDiff.resolves(gitDiff);
      localCollectionsRepoStub.getAllCollectionsByIds.withArgs(fakeAddedCollectionsIds).resolves(fakeAddedCollections);

      await syncCollectionsUseCase.run();

      assert.ok(storedCollectionsRepoStub.setCollections.calledOnceWithExactly(expectedAddedCollections));
    });
  });
});
