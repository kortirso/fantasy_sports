module.exports = {
  presets: [
    [
      '@babel/preset-typescript',
      { targets: { node: 'current' } }
    ]
  ],
  plugins: ['@babel/plugin-transform-flow-strip-types']
};
