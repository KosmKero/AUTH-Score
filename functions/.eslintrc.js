
module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],

    "linebreak-style": 0, // Αγνοεί το σφάλμα CRLF (Windows) vs LF (Linux)
    "object-curly-spacing": 0, // Αγνοεί τα κενά μέσα στις αγκύλες { }
    "max-len": 0, // Αγνοεί το όριο των 80 χαρακτήρων ανά γραμμή
    "indent": 0, // Αγνοεί τα σφάλματα στα tabs/spaces
    "no-unused-vars": 0, // Δεν σε κόβει αν έχεις μεταβλητές που δεν χρησιμοποίησες
    "comma-dangle": 0 // Αγνοεί αν ξέχασες ή έβαλες επιπλέον κόμμα στο τέλος
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
