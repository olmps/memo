import * as assert from "assert";
import { objectsEqual } from "#utils/deep-equals";

describe("objectsEqual", () => {
  it("should return true when two objects are strictly equal", () => {
    const objectA = { a: { n: 0 } };
    const objectB = { a: { n: 0 } };

    const deepEqual = objectsEqual(objectA, objectB);

    assert.ok(deepEqual);
  });

  it("should return false when two objects aren't strictly equal", () => {
    const objectA = { a: { n: 0 } };
    const objectB = { a: { n: "0" } };

    const deepEqual = objectsEqual(objectA, objectB);

    assert.ok(!deepEqual);
  });
});
