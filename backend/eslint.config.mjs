import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['dist/**', 'node_modules/**', 'coverage/**'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    languageOptions: {
      parserOptions: { sourceType: 'module' },
      globals: { process: 'readonly', NodeJS: 'readonly', console: 'readonly' },
    },
    rules: {
      // Nest relies on decorator metadata; unused vars still matter.
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_' },
      ],
      '@typescript-eslint/no-explicit-any': 'error',
      // CLAUDE.md §38 — logging goes through Nest's Logger, never console.
      'no-console': 'error',
    },
  },
);
