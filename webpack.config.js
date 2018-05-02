const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  context: path.resolve(__dirname, 'app'),
  entry: './centerbyweight.moon',
  mode: 'development',
  module: {
    rules: [
      {
        test: /\.moon$/,
        use: [
          'fengari-loader',
          'moonscript-loader',
        ]
      },
    ]
  },
  plugins: [
    new HtmlWebpackPlugin('MMM: lunar low-gravity scripting playground'),
  ],
}
