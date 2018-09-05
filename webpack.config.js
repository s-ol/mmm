const fs = require('fs');
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

const config = {
  context: path.resolve(__dirname, 'app'),
  entry: './index.moon',
  mode: 'development',
  plugins: [
    new HtmlWebpackPlugin({ title: 'MMM: lunar low-gravity scripting playground' }),
  ],
};

const dependencies = {
  'svg.js': 'svg.js',
};
fs.readdirSync(config.context).forEach(file => {
  if (file.endsWith('.moon') && !file.endsWith('.server.moon')) {
    const basename = file.replace(/(\.client)?\.moon$/, '');
    dependencies[`app.${basename}`] = `./${file}`;
  }
});

config.module = {
  rules: [
    {
      test: /\.moon$/,
      use: [
        {
          loader: 'fengari-loader',
          options: {
            dependencies,
          },
        },
        'moonscript-loader',
      ]
    },
  ]
};

module.exports = config;
