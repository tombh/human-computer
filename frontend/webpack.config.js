const ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  devServer: {
    contentBase: 'build',
    historyApiFallback: true
  },
  entry: [
    __dirname + '/app/scripts/app.coffee',
    __dirname + '/app/styles/main.sass',
  ],
  module: {
    rules: [
    {
      test: /\.coffee$/,
      use: "coffee-loader"
    },
    {
      test: /\.sass|\.scss$/,
      use: ExtractTextPlugin.extract({
        use: ["css-loader", "sass-loader"]
      }),
    }
    ],
  },
  output: {
    filename: 'main.js',
    path: __dirname + '/build/assets'
  },
  plugins: [new ExtractTextPlugin('styles.css')],
  resolve: {
    modules: [
      __dirname,
      'node_modules',
      './app/scripts/',
    ],
    extensions: ['.css', '.scss', '.sass', '.js', '.coffee']
  }
}
