import * as assert from "assert";
import * as sinon from "sinon";
import { ShellGateway } from "@data/gateways/shell-gateway";
import { GitRepository } from "@data/repositories/git-repository";

describe("GitRepository", () => {
  const shellMock = sinon.createStubInstance(ShellGateway);
  const gitRepo = new GitRepository(shellMock);

  afterEach(() => {
    shellMock.run.reset();
  });

  it("should use rev-list to fetch the last merge commit hash", async () => {
    const expectedCommand = "git rev-list --min-parents=2 --max-count=1 HEAD";

    await gitRepo.lastMergeCommitHash();
    const shellCommand = shellMock.run.lastCall.lastArg as string;

    assert.strictEqual(shellCommand, expectedCommand);
  });

  it("should use rev-parse to fetch the last commit hash", async () => {
    const expectedCommand = "git rev-parse HEAD";

    await gitRepo.lastCommitHash();
    const shellCommand = shellMock.run.lastCall.lastArg as string;

    assert.strictEqual(shellCommand, expectedCommand);
  });

  describe("gitDiff", () => {
    const baseCommitHash = "baseHash";
    const headCommitHash = "headHash";

    it("base commit hash must precede head commit hash", async () => {
      const expectedGitDiffCommand = `git diff ${baseCommitHash} ${headCommitHash}`;

      await gitRepo.gitDiff(baseCommitHash, headCommitHash);
      const shellCommand = shellMock.run.lastCall.lastArg as string;

      assert.strictEqual(shellCommand, expectedGitDiffCommand);
    });

    it("should include name status flag when included in options", async () => {
      const expectedGitDiffCommand = `git diff --name-status ${baseCommitHash} ${headCommitHash}`;

      await gitRepo.gitDiff(baseCommitHash, headCommitHash, { nameStatus: true });
      const shellCommand = shellMock.run.lastCall.lastArg as string;

      assert.strictEqual(shellCommand, expectedGitDiffCommand);
    });
  });
});
