const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
const CompressionPlugin = require('compression-webpack-plugin');
const { InjectManifest } = require('workbox-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');

module.exports = (env, argv) => {
  const isProduction = argv.mode === 'production';
  
  return {
    entry: './frontend/src/index.js',
    output: {
      path: path.resolve(__dirname, 'frontend/build'),
      filename: '[name].[contenthash].js',
      chunkFilename: '[name].[contenthash].chunk.js',
      publicPath: '/',
      clean: true,
    },
    module: {
      rules: [
        {
          test: /node_modules\/react-datepicker\/dist\/index\.es\.js$/,
          use: [
            {
              loader: 'source-map-loader',
              options: {
                filterSourceMappingUrl: (url, resourcePath) => {
                  // Suppress source map warnings for react-datepicker
                  if (resourcePath.includes('react-datepicker')) {
                    return false;
                  }
                  
                  return true;
                },
              },
            },
          ],
        },
        {
          test: /\.(js|jsx)$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: [
                '@babel/preset-env',
                '@babel/preset-react'
              ],
              plugins: [
                '@babel/plugin-transform-runtime',
              ],
            },
          },
        },
        {
          test: /\.css$/,
          use: ['style-loader', 'css-loader', 'postcss-loader'],
        },
        {
          test: /\.(png|svg|jpg|jpeg|gif)$/i,
          type: 'asset/resource',
        },
      ],
    },
    resolve: {
      extensions: ['.js', '.jsx', '.ts', '.tsx'],
      alias: {
        '@': path.resolve(__dirname, 'frontend/src'),
      },
    },
    optimization: {
      minimize: isProduction,
      minimizer: [
        new TerserPlugin({
          terserOptions: {
            compress: {
              drop_console: isProduction,
            },
          },
        }),
      ],
      splitChunks: {
        chunks: 'all',
        minSize: 20000,
        minChunks: 1,
        maxAsyncRequests: 30,
        maxInitialRequests: 30,
        cacheGroups: {
          defaultVendors: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            chunks: 'all',
            priority: -10,
          },
          framework: {
            test: /[\\/]node_modules[\\/](react|react-dom|react-router-dom)[\\/]/,
            name: 'framework',
            chunks: 'all',
            priority: 10,
          },
          ui: {
            test: /[\\/]node_modules[\\/](@radix-ui|framer-motion|lucide-react)[\\/]/,
            name: 'ui',
            chunks: 'all',
            priority: 5,
          },
          charts: {
            test: /[\\/]node_modules[\\/](recharts)[\\/]/,
            name: 'charts',
            chunks: 'all',
            priority: 5,
          },
          utils: {
            name: 'utils',
            test: /[\\/]src[\\/]utils[\\/]/,
            chunks: 'all',
            enforce: true,
          },
          common: {
            name: 'common',
            minChunks: 2,
            chunks: 'async',
            priority: -20,
            reuseExistingChunk: true,
          },
        },
      },
      runtimeChunk: 'single',
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: './frontend/public/index.html',
      }),
      new CopyPlugin({
        patterns: [
          { 
            from: 'frontend/public',
            to: '.', 
            globOptions: {
              ignore: ['**/index.html'],
            },
          },
        ],
      }),
      ...(isProduction 
        ? [
            new CompressionPlugin({
              algorithm: 'gzip',
              test: /\.(js|css|html|svg)$/,
              threshold: 10240,
              minRatio: 0.8,
            }),
            new InjectManifest({
              swSrc: './frontend/src/service-worker.js',
              swDest: 'service-worker.js',
              exclude: [/\.map$/, /asset-manifest\.json$/],
            }),
            process.env.ANALYZE === 'true' && new BundleAnalyzerPlugin(),
          ].filter(Boolean)
        : []
      ),
    ],
    devServer: {
      historyApiFallback: true,
      port: process.env.PORT || 3000,
      static: {
        directory: path.join(__dirname, 'frontend/public'),
      },
      hot: true,
    },
    performance: {
      hints: isProduction ? 'warning' : false,
      maxEntrypointSize: 512000,
      maxAssetSize: 512000,
    },
  };
}; 