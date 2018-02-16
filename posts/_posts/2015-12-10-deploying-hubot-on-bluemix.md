---
layout: post
title: "Deploying Hubot on Bluemix"
tags: [bluemix, hubot]
description: >
  How to deploy GitHub's Hubot on IBM's PaaS Bluemix
---

*Update: These instructions have been merged in to Github's repo via [Hubot Pull
*Request #1095](https://github.com/github/hubot/pull/1095)*

## Why Hubot?

Hubot is great.

From hubot's website:

> __Hubot is your company's robot__. Install him in your company to dramatically
improve and reduce employee efficiency.

> Today's version of Hubot is open source, written in CoffeeScript on Node.js,
and easily deployable. More importantly, Hubot is a __standardized__ way to
share scripts between everyone's robots.

It allows you to have scripts running anywhere you can type - whether that be
Slack, or Twitter, or GroupMe, or iMessage, or IRC... (full list
[here](https://github.com/github/hubot/blob/master/docs/adapters.md)). You can
write your own or use one of the hundreds of scripts that are openly available
on [GitHub](https://github.com/github/hubot-scripts).

[Official Docs Here](https://hubot.github.com/)

{% include ad-blog.html %}

## Fun things to do with Hubot

![picture time](/assets/images/post-images/hubot.png)

## Let's get down to business

Prereqs:

  1. Follow the [Hubot Getting Started](https://hubot.github.com/docs/) guide 1.
  Have a [Bluemix account](https://bluemix.net) 1. Install the [Cloud Foundry
  CLI](https://github.com/cloudfoundry/cli/releases)

The official hubot docs point you to Heroku as a hosting mechanism. Unlike
Heroku, the free tier on Bluemix supports 24/7 uptime, so you don't need to go
through the hassle of setting up something like
[hubot-heroku-keepalive](https://github.com/hubot-scripts/hubot-heroku-keepalive).

First we need to define a `manifest.yml` file in the root directory (and delete
the generated `procfile`). The contents of the manifest at the bare minimum
should look like:

~~~yaml
applications:
- buildpack: https://github.com/jthomas/nodejs-v4-buildpack.git
  command: ./bin/hubot --adapter slack
  path: .
  instances: 1
  memory: 256M
~~~

In this example, we're using the slack adapter (as shown by the start command).
Of course, the start command can be whatever you need to start your specific
hubot. You can optionally set a `host`, and `name`, and much more, or you can
set those up through the Bluemix GUI in the dashboard. For thorough
documentation on what the `manifest.yml` file does and how it used and how to
configure your own, see [these
docs](https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html).

You then need to connect your hubot project to Bluemix:

~~~bash
$ cd your_hubot_project
$ cf api https://api.ng.bluemix.net
$ cf login
~~~

This will prompt you with your login credentials. Then to deploy your hubot, all
you need to do is:

~~~bash
$ cf push NAME_OF_YOUR_HUBOT_APP
~~~

Note: if you do not specify a `name` and `host` in your manifest, you will have
needed to create a `Node.js` Cloudfoundry app in the Bluemix dashboard. You then
use the name that of that app in your `cf push` command. For very thorough
documentation on deploying a Node.js app to Bluemix, please [read
here](https://www.ng.bluemix.net/docs/starters/nodejs/index.html), for very
thorough documentation of the command line interface, please [read
here](https://www.ng.bluemix.net/docs/cli/reference/cfcommands/index.html).

Finally you will need to add the environment variables to the website to make
sure it runs properly. You can either do it through the GUI (under your app's
dashboard) or you can use the command line, as follows (example is showing slack
as an adapter):

~~~bash
$ cf set-env NAME_OF_YOUR_HUBOT_APP HUBOT_SLACK_TOKEN TOKEN_VALUE
~~~

## Shameless plug

hey, this wouldn't be a blog post if I didn't shamelessly plug my own hubot
script - [Hubot-Hamilton](https://github.com/kauffecup/hubot-hamilton)... it...
posts Hamilton lyrics.

## Further Reading

  - [Setting up a Build Pipleline in
     Bluemix](https://www.ng.bluemix.net/docs/#services/DeliveryPipeline/index.html#getstartwithCD) -
     use this for integration with git and automatic builds/delivery
  - [Deploying Cloud Foundry Apps To Bluemix](https://www.ng.bluemix.net/docs/cfapps/runtimes.html)
  - [Deploying Node.js Apps to Bluemix](https://www.ng.bluemix.net/docs/starters/nodejs/index.html)
  - [Setting up your manifest](https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html)
  - [Understanding the CF CLI](https://www.ng.bluemix.net/docs/cli/reference/cfcommands/index.html)
