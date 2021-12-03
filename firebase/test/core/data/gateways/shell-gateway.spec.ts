import * as assert from "assert";
import * as sinon from "sinon";
import * as child_process from "child_process";
import { ShellGateway } from "#data/gateways/shell-gateway";
import ShellError from "#faults/errors/shell-error";

describe("ShellGateway", () => {
  // TODO(matuella): How to mock while maintaining types?
  // This way, we won't have to call `fsMock.expect("unsafeMethodCall")` and could
  // possibly use `createSinonStub`
  let childProcessMock: sinon.SinonMock;

  beforeEach(() => {
    childProcessMock = sinon.mock(child_process);
  });

  afterEach(() => {
    sinon.restore();
  });

  it("should reject when exec returns an error", async () => {
    const shellGateway = new ShellGateway();

    childProcessMock.expects("exec").yields("Exception", "", "");

    await assert.rejects(() => shellGateway.run("any"), ShellError);
  });

  it("should reject when exec stderr is not empty", async () => {
    const shellGateway = new ShellGateway();

    childProcessMock.expects("exec").yields(null, "", "Exception");

    await assert.rejects(() => shellGateway.run("any"), ShellError);
  });

  it("should resolve the stdout when exec stderr and error are not set", async () => {
    const expectedOutput = "Output";
    const shellGateway = new ShellGateway();

    childProcessMock.expects("exec").yields(null, expectedOutput, "");
    const output = await shellGateway.run("any");

    assert.strictEqual(output, expectedOutput);
  });
});
