module.exports = {
  presets: ['@babel/preset-env'],
  plugins: [
    [
      'module-resolver',
      {
        root: ['./desktop/core/src/desktop/js']
      }
    ],
    '@babel/plugin-syntax-dynamic-import'
  ],
  overrides: [
    {
      test: /.*(Autocomplete|Syntax)Parser\.js/,
      compact: true
    }
  ]
};
