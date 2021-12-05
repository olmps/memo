import * as sinon from "sinon";

type StubbedClass<T> = sinon.SinonStubbedInstance<T> & T;

/** Creates a type-casted sinon Stub. */
export default function createSinonStub<T>(
  constructor: sinon.StubbableType<T>,
  sandbox?: sinon.SinonSandbox
): StubbedClass<T> {
  if (sandbox !== undefined) {
    return sandbox.createStubInstance(constructor) as StubbedClass<T>;
  }

  return sinon.createStubInstance(constructor) as StubbedClass<T>;
}
