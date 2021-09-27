import * as sinon from "sinon";

type StubbedClass<T> = sinon.SinonStubbedInstance<T> & T;

/** Creates a type-casted sinon Stub. */
export default function createSinonStub<T>(constructor: sinon.StubbableType<T>): StubbedClass<T> {
  return sinon.createStubInstance(constructor) as StubbedClass<T>;
}
