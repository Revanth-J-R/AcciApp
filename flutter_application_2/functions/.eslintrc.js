module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
<<<<<<< HEAD
    ecmaVersion: 2021, // Updated to a more recent version
=======
    "ecmaVersion": 2018,
>>>>>>> 655301e (Initial commit)
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
<<<<<<< HEAD
    "max-len": ["error", {code: 80}],
    "indent": ["error", 2],
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "object-curly-spacing": ["error", "never"],
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
=======
    "no-unused-vars": "off",
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
>>>>>>> 655301e (Initial commit)
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
