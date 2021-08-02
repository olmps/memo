// eslint-disable-next-line no-undef
module.exports = {
  root: true,
  env: {
    commonjs: true,
    node: true,
  },
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint", "prettier"],
  extends: ["eslint:recommended", "plugin:@typescript-eslint/recommended", "prettier"],
  parserOptions: {
    ecmaVersion: 2020,
  },
  ignorePatterns: ["**/dist"],
  rules: {
    "prettier/prettier": "warn",

    // Custom
    "@typescript-eslint/no-non-null-assertion": "off",
  },
};
