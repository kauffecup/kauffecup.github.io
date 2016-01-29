---
layout: post
title:  "Sharing Code between React Web and Native Apps"
date:   2016-01-29 10:35:44 -0500
categories: react reactnative
---

*TL;DR: Here's a way to share application logic between a React Web app and a
React Native app, while keeping the individual component rendering unique to
each platform. The example app can be found [on GitHub][gh].*

## The app

React Native                              |  React Web
:----------------------------------------:|:-------------------------------------:
![native](http://i.imgur.com/OvstUk4.gif) | ![web](http://i.imgur.com/siF0aYJ.gif)

The app itself is a very simple Hello World (ish) app. Not only does it show
"Hello World"... but when you click (or tap) it... it changes from red to blue!
woah!

## Motivation

*Writing React apps is awesome for both web and mobile... so why not share code
between your two implementations?*

Let me just say right off the bat that React Native/React wasn't designed to be
a "write once, run everywhere" framework. Facebook constantly calls it a "learn
once, write everywhere" framework - the idea being that you tailor your
implementation to the platform you're writing for. That said, you can still
share a great deal of logic between your applications.

In this post I'll be discussing how you can take a more "middle of the road"
approach between these mentalities. We'll be sharing all the application logic
while keeping the rendering code specific to each platform.

We'll be assuming some knowledge of [React][r], [React Native][rn], and
[Redux][rx].

## Initial Setup + Directory Overview

First we need to initialize our project. We're going to follow the steps
dictated in Facebook's [getting started][gs] guide:

{% highlight bash %}
$ npm install -g react-native-cli
$ react-native init ReactNativeWebHelloWorld
{% endhighlight %}

We now have a directory that looks like:

{% highlight bash %}
ReactNativeWebHelloWorld
|-- android
|-- ios
|-- node_modules
|-- .flowconfig
|-- .gitignore
|-- .watchmanconfig
|-- index.android.js
|-- index.ios.js
+-- package.json
{% endhighlight %}

This contains all the files we'll need for both our iOS and Android app. We now
create the following directories and files to configure and run our Web app:

{% highlight bash %}
ReactNativeWebHelloWorld
+-- web
    |-- public
    |   +-- index.html
    +-- webpack
        |-- web.dev.config.js
        +-- web.prod.config.js
{% endhighlight %}

The contents of [`index.html`][ix], [`web.dev.config.js`][wpd], and
[`web.prod.config.js`][wpp] can all be found in the [GitHub][gh] repo - we'll dive
into them more later (_but if you want to click on them now, by all means... do
it!_).

After our directory structure is configured, we install the dependencies we'll
be needing for the application:

{% highlight bash %}
$ npm install --save babel babel-polyfill ...
$ npm install --save-dev autoprefixer babel-core ...
{% endhighlight %}

For a full list of dependencies, check out the [`package.json`][pg].

For the final bit of set up (_woo!_), we initialize all of the files for our
actual application. We'll be making a fairly "traditional" React/Redux app:

{% highlight bash %}
ReactNativeWebHelloWorld
+-- app
    |-- actions
    |-- constants
    |-- reducers
    |-- store
    |-- native
    |   |-- components
    |   |-- containers
    |   +-- style
    +-- web
        |-- components
        |-- containers
        +-- style
{% endhighlight %}

At this point it should be getting fairly clear what's going on. We have three
different entry points for our three different apps: `index.ios.js`,
`index.android.js`, and `app/web/index.js`. The iOS and Android entry points load
the components and containers from `app/native`, and the web entry point loads
components and containers from `app/web`. This brings us to our...

## Application Code Structure

I'm not going to go through every single file and that file's place and purpose
in this whole mess, but I am going to point out some key differences between
native and web.

Let's look at the app entry points, shall we? `index.ios.js` looks like:

{% highlight js %}
import React, { Component, AppRegistry } from 'react-native';
import Root           from './app/native/containers/Root';
import configureStore from './app/store/configureStore.prod.js';

const store = configureStore();

class ReactNativeHelloWorld extends Component {
  render() {
    return (
      <Root store={store} />
    );
  }
}

AppRegistry.registerComponent('ReactNativeWebHelloWorld', () => ReactNativeHelloWorld);
{% endhighlight %}

And `app/web/index.js`...

{% highlight js %}
import React          from 'react';
import { render }     from 'react-dom';
import Root           from './containers/Root';
import configureStore from '../store/configureStore';

// load our css
require('./styles/style.less');

const store = configureStore();
const rootElement = document.getElementById('root');

render( <Root store={store} />, rootElement );
{% endhighlight %}

Ok, so what are the differences that we care about?

The main thing to notice is how the top-level component renders itself into
either the page or the app. In native-land, we have to explicitly define a
top-level react component that registers itself with the app registry, whereas
in web-town we can, using `ReactDom`, render our `Root` directly into our
root element.

WHAT DOES THAT MEAN!?

Basically, React Native and React Web have different ways of instantiating the
top-level component.

*It's these differences that require us to keep the rendering logic unique to
each platform.*

Let's also examine the `HelloWorld` component's `render` method in both cases.
In Native, it looks like:

{% highlight js %}
render() {
  const { onPress, color } = this.props;
  const style = StyleSheet.create({
    helloWorld: { color: color, textAlign: 'center' }
  });
  return (
    <View>
      <Text onPress={onPress} style={style.helloWorld}>Hello World</Text>
    </View>
  );
}
{% endhighlight %}

And for web, it looks like:

{% highlight js %}
render() {
  const { onClick, color } = this.props;
  return (
    <div className="hello-world" onClick={onClick} style={ {color: color} }>Hello World</div>
  );
}
{% endhighlight %}

This reinforces that point in bold up there about why we need to keep the
rendering logic unique to each platform. React native deals in `<View>`s and
`<Text>`s whereas the web deals with `<div>`s and `<span>`s. Not only that, but
both the event system and style system are different.

*But let's look at what's shared between them for a second...*

When instantiating the `HelloWorld` component, `app/native/containers/App.js`
defines...

{% highlight js %}
<HelloWorld
  onPress={() => dispatch(toggleColor())}
  color={color}
/>
{% endhighlight %}

and `app/web/containers/App.js` defines...

{% highlight js %}
<HelloWorld
  onClick={() => dispatch(toggleColor())}
  color={color}
/>
{% endhighlight %}

Both `dispatch` methods are injected via `react-redux`, and `toggleColor` is
imported from the same `actions` file. *ONLY THE RENDERING IS DIFFERENT! THE
APPLICATION LOGIC IS SHARED! It's a leap day miracle!*

Rather than go through each individual difference and similarity one by one (as
that would result in a novel's worth of explanation) we're going to move on to
the scripts defined in `package.json` that allow you to build and run this bad
boy...

## Configured Scripts

### Running in dev/production

There are 8 defined scripts in [package.json][pg]:

  1. `start`
  1. `ios-bundle`
  1. `ios-dev-bundle`
  1. `android-bundle`
  1. `android-dev-bundle`
  1. `web-bundle`
  1. `web-dev`

### `start`

`start` is used when running/bundling the native application. When you open
either the xcode project or the android studio project and hit "run", it
kicks off a node server via the `start` command. Every time you make a
JavaScript change, instead of needing to rebuild and recompile your application,
you simply refresh the app and the changes are magically there. As this is not
a React Native guide I will not be going into more detail than that - further
information can be found on Facebook's [React Native Getting Started][gs] guide.

### bundlin

For `ios-bundle`, `ios-dev-bundle`, `android-bundle`, and `android-dev-bundle`,
the script builds the JavaScript bundle (either minified or not-minified
depending on the presence of `dev` or not), and places it where the
corresponding project expects it to be for running locally on your device.
Again, you can find more info on running on your device on Facebook's
[React Native Getting Started][gs].

### web town

`web-dev` kicks off a webpack server on port 3001, it utilizes hot reloading
with some redux-time-machine-magic to have a crazy awesome dev experience where
you can rewind and revert actions in your application.

`web-bundle` creates a minified JavaScript bundle (that also houses the minified
css) and places it next to the `index.html` in `web/public` that you can serve
with any static file server.

### clear-cache

Every now and then, when React Native is doing it's thing, you'll swear that
you've changed something, but alas it is still causing your app to break! oh
noes! what do we do!

`npm run clear-cache`

## Further Configuration

Webpack sets the `PLATFORM_ENV` environment variable to be `web`. You can use
this check to conditionally load different files depending on if you're building
your native or web app. For example - you can abstract out the difference
between local storage mechanisms.

## What does this get you?

Well, first of all, this was pretty fun to set up. Often it's good to do
something in the pure spirit of education. But if that's not enough for ya,
consider any bug that's caused in the action/reducer/request layer of your app
- fixing it once will abolish the bug in both your web and mobile versions.

It also allows for pretty rapid development on both platforms. I was able to get
one of my react/redux apps running on mobile feature-complete after about two
days of effort.

## phew!

Thanks for stickin' with me, through this one. I know it was alot.

[rn]:  https://facebook.github.io/react-native/
[gs]:  https://facebook.github.io/react-native/docs/getting-started.html
[rr]:  https://github.com/rackt/react-redux
[rx]:  http://redux.js.org/
[r]:   https://facebook.github.io/react/
[gh]:  https://github.com/kauffecup/react-native-web-hello-world
[ix]:  https://github.com/kauffecup/react-native-web-hello-world/blob/master/web/public/index.html
[wpd]: https://github.com/kauffecup/react-native-web-hello-world/blob/master/web/webpack/web.dev.config.js
[wpp]: https://github.com/kauffecup/react-native-web-hello-world/blob/master/web/webpack/web.prod.config.js
[pg]:  https://github.com/kauffecup/react-native-web-hello-world/blob/master/package.json
