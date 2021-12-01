import * as assert from "assert";
import * as fs from "fs";
import * as sinon from "sinon";
import { FileSystemGateway } from "#data/gateways/filesystem-gateway";
import FilesystemError from "#faults/errors/filesystem-error";

describe("FileSystemGateway", () => {
  const defaultEncoding = { encoding: "utf-8" };
  const fakeCwd = "test_cwd";
  const fakeFileDir = "file/dir";

  const fakeFiles = ["file1", "file2"];

  const expectedDirectory = `${fakeCwd}/${fakeFileDir}`;

  const fakeFilesContents = ["file1Contents", "file2Contents"];

  // TODO(matuella): How to mock while maintaining types?
  // This way, we won't have to call `fsMock.expect("unsafeMethodCall")` and could
  // possibly use `createSinonStub`
  let fsMock: sinon.SinonMock;

  beforeEach(() => {
    fsMock = sinon.mock(fs.promises);
    sinon.stub(process, "cwd").returns(fakeCwd);
  });

  afterEach(() => {
    sinon.restore();
  });

  it("should reject when readdir throws", async () => {
    const fsGateway = new FileSystemGateway();
    fsMock.expects("readdir").rejects();
    await assert.rejects(() => fsGateway.readDirFilesAsStrings("any"), FilesystemError);
  });

  it("should reject when readFile throws", async () => {
    const fsGateway = new FileSystemGateway();
    fsMock.expects("readdir").returns(fakeFiles);
    fsMock.expects("readFile").rejects();
    await assert.rejects(() => fsGateway.readDirFilesAsStrings("any"), FilesystemError);
  });

  it("should return all contained files in passed directory", async () => {
    const fsGateway = new FileSystemGateway();
    fsMock.expects("readdir").withArgs(expectedDirectory).once().returns(fakeFiles);
    fsMock
      .expects("readFile")
      .withArgs(`${expectedDirectory}/${fakeFiles[0]}`, defaultEncoding)
      .once()
      .returns(fakeFilesContents[0]);
    fsMock
      .expects("readFile")
      .withArgs(`${expectedDirectory}/${fakeFiles[1]}`, defaultEncoding)
      .once()
      .returns(fakeFilesContents[1]);

    const result = await fsGateway.readDirFilesAsStrings(fakeFileDir);

    assert.deepStrictEqual(result, fakeFilesContents);
    fsMock.verify();
  });
});
