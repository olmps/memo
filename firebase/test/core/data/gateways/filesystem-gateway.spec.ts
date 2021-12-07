import * as assert from "assert";
import * as fs from "fs";
import * as sinon from "sinon";
import { FileSystemGateway } from "#data/gateways/filesystem-gateway";
import FilesystemError from "#faults/errors/filesystem-error";

describe("FileSystemGateway", () => {
  const defaultEncoding: fs.BaseEncodingOptions = { encoding: "utf-8" };
  const fakeCwd = "test_cwd";
  const fakeFileDir = "file/dir";
  const expectedDirectory = `${fakeCwd}/${fakeFileDir}`;

  let sandbox: sinon.SinonSandbox;
  let fsStub: sinon.SinonStubbedInstance<typeof fs.promises>;

  beforeEach(() => {
    sandbox = sinon.createSandbox();
    fsStub = sandbox.stub(fs.promises);
    sandbox.stub(process, "cwd").returns(fakeCwd);
  });

  afterEach(() => {
    sandbox.restore();
  });

  describe("readDirFileAsStrings", () => {
    const fakeFiles = ["file1", "file2"];
    const fakeFilesContents = ["file1Contents", "file2Contents"];

    it("should reject when readdir throws", async () => {
      const fsGateway = new FileSystemGateway();
      fsStub.readdir.rejects();
      await assert.rejects(() => fsGateway.readDirFilesAsStrings("any"), FilesystemError);
    });

    it("should reject when readFile throws", async () => {
      const fsGateway = new FileSystemGateway();
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      fsStub.readdir.resolves(fakeFiles);
      fsStub.readFile.rejects();
      await assert.rejects(() => fsGateway.readDirFilesAsStrings("any"), FilesystemError);
    });

    it("should return all contained files in passed directory", async () => {
      const fsGateway = new FileSystemGateway();
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      fsStub.readdir.withArgs(expectedDirectory).resolves(fakeFiles);
      fsStub.readFile.withArgs(`${expectedDirectory}/${fakeFiles[0]}`, defaultEncoding).resolves(fakeFilesContents[0]);
      fsStub.readFile.withArgs(`${expectedDirectory}/${fakeFiles[1]}`, defaultEncoding).resolves(fakeFilesContents[1]);

      const result = await fsGateway.readDirFilesAsStrings(fakeFileDir);

      assert.deepStrictEqual(result, fakeFilesContents);
      assert.ok(fsStub.readFile.calledTwice);
      assert.ok(fsStub.readdir.calledOnce);
    });
  });

  describe("readFileAsString", () => {
    const fakeFile = "file1";
    const fakeFileContents = "file1Contents";

    it("should reject when readFile throws", async () => {
      const fsGateway = new FileSystemGateway();
      fsStub.readFile.rejects();
      await assert.rejects(() => fsGateway.readFileAsString("any"), FilesystemError);
    });

    it("should return file in passed directory", async () => {
      const fsGateway = new FileSystemGateway();
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      fsStub.readFile.withArgs(`${fakeCwd}/${fakeFile}`, defaultEncoding).resolves(fakeFileContents);

      const result = await fsGateway.readFileAsString(fakeFile);

      assert.deepStrictEqual(result, fakeFileContents);
      assert.ok(fsStub.readFile.calledOnce);
    });
  });
});
