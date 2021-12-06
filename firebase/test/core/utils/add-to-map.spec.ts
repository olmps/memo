import * as assert from "assert";
import { addToMap } from "#utils/add-to-map";

describe("addToMap", () => {
  it("should add a list of values to an existing map key", () => {
    const mapKey = "key";
    const mapValues = [1, 2, 3];
    const map = new Map<string, number[]>([[mapKey, mapValues]]);
    const newValues = [4, 5, 6];
    const expectedUpdatedValues = mapValues.concat(newValues);

    addToMap(map, mapKey, ...newValues);

    assert.deepStrictEqual(map.get(mapKey), expectedUpdatedValues);
  });

  it("should add a list of values to an non-existing map key", () => {
    const mapKey = "key";
    const map = new Map<string, number[]>();
    const newValues = [1, 2, 3];

    addToMap(map, mapKey, ...newValues);

    assert.deepStrictEqual(map.get(mapKey), newValues);
  });
});
