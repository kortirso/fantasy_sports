const { webpackConfig, merge } = require('@rails/webpacker')

const vue = require('./loaders/vue')

module.exports = merge(vue, webpackConfig)
