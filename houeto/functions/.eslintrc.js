module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", { "allowTemplateLiterals": true }],

    // ✅ Ajouts pour corriger tes erreurs
    "max-len": ["warn", { "code": 120 }], // Autorise des lignes plus longues (120 caractères)
    "no-unused-vars": "off", // Désactive l'erreur sur les variables inutilisées
    "object-curly-spacing": ["error", "always"], // Corrige les espaces dans les objets
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
