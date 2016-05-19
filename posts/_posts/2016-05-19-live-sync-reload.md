---
layout: post
title: "Live Sync Reload"
tags: [bluemix, webpack]
image:
description: >
  Using the magic of webpack middleware with bluemix livesync - rebuild your
  client-side code without redploying.
---

*Example app [here][gh].*

Who's in the mood for a good hack today? One that certainly works, is kinda cool
but probably has no business being in any sort of production environment. It may
or may not even be a good idea for a dev environment - that I'll leave for you
to decide.

We're going to be combining [Weback's dev middleware][wdm] with [Bluemix's Live
Sync][ls]. The end game allows you to change code, hit save on your local IDE,
have those changes propagate up to Bluemix, and trigger an automagic Webpack
rebundle, with 0 downtime or reploys.

## motivation

Let's get this out of the way early.

[Bluemix's Live Sync][ls] makes for a great debugging/development process.
Hitting save, and having your code running immediately in the cloud is pretty
awesome. However... if your client code uses any kind of transpiling - ES6,
React, etc. this won't work for you. You need that extra build step! Once your
code is in the cloud you need to tell Webpack to rebuild it.

Enter Webpack Dev and Webpack Hot Middleware.

They do exactly what we want! On file change, they rebuild our dev bundle,
meaning you can take advantage of what [Bluemix Live Sync][ls] has to offer
despite having a complicated set up.

## let's get down to business

This post isn't going to dilly-dally in the nitty-gritties of how to set up
livesync, for fear of simply replicating [the official docs][ls] (which are
awesomely thorough). Essentially you create a launch configuration which allows
you to use the online IDE for making code changes. When you save these changes,
they get injected into your running app without a redeploy. Now this is all well
and dandy, but often you prefer using your IDE of choice. Further down on [that
page][ls] are steps for syncing your local files with the files on Bluemix.

To set up with webpack, we'll be walking through an example application. You can
find the completed code [at this GitHub Repo][gh]. Our application directory has
the following structure:

~~~
app
  |--index.js
  +--style.css
launchConfigurations
  +--livesync-reload.launch
public
  +--index.html
server
  |--app.js
  +--webpack.config
package.json
project.json
~~~

Let's set up our Webpack config. The final product is [here][wgh] if you want to
skip to the end. The first thing we're going to do is define our entry and output:

~~~js
const webpack = require('webpack');
const path = require('path');
module.exports = {
  entry: [
    'webpack-hot-middleware/client',
    path.join(__dirname, '../app/index.js')
  ],
  output: {
    path: path.join(__dirname, '../public'),
    filename: 'bundle.js',
    publicPath: '/'
  }
};
~~~

Note that in the entry array, the first string is `webpack-hot-middleware/client`,
this connects to the server to receive notifications when the bundle rebuilds
and then updates your client bundle accordingly.

Next we're going to define our module loaders. Just to make things complicated
(well really to demonstrate why would want this at all) let's build our client
code with React and ES6:

~~~js
module.exports = {
  entry: [ ... ],
  output: { ... },
  module: {
    loaders: [
      { test: /\.css$/, loader: 'style!css' },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015', 'react'],
          plugins: [['react-transform', {
            transforms: [{
              transform: 'react-transform-hmr',
              imports: ['react'],
              // this is important for Webpack HMR:
              locals: ['module']
            }, {
              transform: 'react-transform-catch-errors',
              imports: ['react', 'redbox-react']
            }]
          }]]
        }
      }
    ]
  }
~~~

Now we're going to add some plugins and turn on sourcemaps:

~~~js
module.exports = {
  devtool: 'cheap-module-eval-source-map',
  entry: [ ... ],
  output: { ... },
  module: { ... },
  plugins: [
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify('development'),
      },
    }),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin()
  ]
};
~~~

And that's it for webpack!

The final bit of server-side-sorcery is to setup the Webpack middleware to use
the config we just created. Assuming we're using express and have created our
server using `const app = new express()`, to configure the Webpack middleware,
we must simply:

~~~js
const webpack = require('webpack');
const webpackDevMiddleware = require('webpack-dev-middleware');
const webpackHotMiddleware = require('webpack-hot-middleware');

const compiler = webpack(config);
app.use(webpackDevMiddleware(compiler, {
  noInfo: true,
  publicPath: config.output.publicPath
}));
app.use(webpackHotMiddleware(compiler));
~~~

View the full version of the [server here][sv].

So now even though [`app/index.js`][ix] uses some fancy React syntax, you can
harness the beauty of [Bluemix Live Sync][ls] to get instant, changes when you
edit locally.

## the sparknotes version

  1. Follow all steps [here][ls]
  1. Setup your [webpack config][wgh]
  1. Setup webpack dev and webpack hot middleware in your [node server][sv]
  1. Prosper

[bx]:  http://bluemix.net/
[ls]:  https://hub.jazz.net/tutorials/livesync/
[gh]:  https://github.com/kauffecup/livesync-reload
[wdm]: https://webpack.github.io/docs/webpack-dev-middleware.html
[wgh]: https://github.com/kauffecup/livesync-reload/blob/master/server/webpack.config
[ix]:  https://github.com/kauffecup/livesync-reload/blob/master/app/index.js
[sv]:  https://github.com/kauffecup/livesync-reload/blob/master/server/app.js
