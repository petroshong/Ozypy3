module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
    jest: true,
  },
  extends: ['react-app'],
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: ['react', 'react-hooks'],
  rules: {
    // Disable console warnings only in development
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    
    // Temporarily disable for development
    'react/prop-types': 'off',
    'arrow-parens': 'off',
    'quotes': 'off',
    'indent': 'off',
    'max-len': 'off',
    'no-unused-vars': 'warn',
    'no-useless-catch': 'warn',
    'react/no-unescaped-entities': 'off',
    'no-case-declarations': 'off',
    
    // Error prevention - keep these enabled
    'no-debugger': 'warn',
    'no-alert': 'warn',
    'no-use-before-define': 'error',
    'no-undef': 'error',
    
    // React specific
    'react/jsx-uses-react': 'error',
    'react/jsx-uses-vars': 'error',
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
    
    // Style - temporarily disable for development
    'semi': ['warn', 'always'],
    'comma-dangle': 'off',
    
    // ES6+
    'arrow-body-style': 'off',
    'prefer-const': 'warn',
    'prefer-destructuring': 'warn',
    'prefer-template': 'warn',
    'no-var': 'error',
  },
  settings: {
    react: {
      version: 'detect',
    },
  },
  overrides: [
    {
      files: [
        '**/*.test.js',
        '**/*.test.jsx',
        '**/*.spec.js',
        '**/*.spec.jsx',
      ],
      env: {
        jest: true,
      },
      rules: {
        'max-len': 'off',
      },
    },
  ],
}; 