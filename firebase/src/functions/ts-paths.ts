import * as path from "path";

import * as rootTSConfig from "../../tsconfig.json";
import * as functionsTSConfig from "../../tsconfig.functions.json";
import * as tsConfigPaths from "tsconfig-paths";

/**
 * Register `tsconfig-paths` "manually".
 *
 * Because we don't have control over the `node` process in Firebase Functions, it is impossible to run `node` using the
 * usual `-r tsconfig-paths/register`, hence why we do it in runtime.
 */
export function registerTSPaths(): void {
  tsConfigPaths.register({
    // This resolve is relative to this file's directory (not to its `.js` output, but to `.ts` instead).
    // Meaning that we resolve to first going to firebase root project (first arg), then to `functions` js output (second
    // arg).
    baseUrl: path.resolve("../../", functionsTSConfig.compilerOptions.outDir),
    paths: rootTSConfig.compilerOptions.paths,
  });
}
