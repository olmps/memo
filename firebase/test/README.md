# Memo Firebase Tests

The `test` folder structure follows the same folders hierarchy than `src` folder, to facilitate between the project
files and their test declarations.

The tests scripts must be ran through the project root folder. The scripts specifications can be verifier in the project
[root `package.json`](../package.json).

## Sinon Type Checking

Some gateways are tested by stubbing Node native packages using [`sinon`](https://sinonjs.org/) test framework.

`sinon` doesn't support native type-checking. Its typing definitions are provided by 
[`DefinitelyTyped`](https://github.com/DefinitelyTyped/DefinitelyTyped) project. In some situations it incorrectly infer
the wrong function signature when it has different overloads. See [this issue](https://github.com/DefinitelyTyped/DefinitelyTyped/issues/36436) for more details.

A clear example is `fs.promises.readdir` function which has 5 different overload functions and `sinon` automatically 
infer the last one as the one that's going to be used. In such scenarios we disable TypeScript type-checking in some `gateway` tests due to this typing inconsistency, although the functions are correctly stubbed/mocked/spied.

For a concrete example refer to [`FileSystemGateway` test file](./core/data/gateways/filesystem-gateway.spec.ts)