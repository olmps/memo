/**
 * Add one or multiple {@link value} to {@link map}, where {@link key} exists.
 *
 * If {@link key} is missing, add an array to it, otherwise push the received values to the existing array.
 */
export function addToMap<K extends string | number | symbol, V>(map: Map<K, V[]>, key: K, ...value: V[]): void {
  if (map.has(key)) {
    map.get(key)!.push(...value);
  } else {
    map.set(key, value);
  }
}
