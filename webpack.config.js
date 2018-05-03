const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  context: path.resolve(__dirname, 'app'),
  entry: './index.moon',
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
    new HtmlWebpackPlugin({ title: 'MMM: lunar low-gravity scripting playground' }),
  ],
}
