---
layout: page
title: Projects
permalink: /projects/
image: assets/images/projects.jpg
format: full
---

## Personal Projects

For more, smaller, bite-sized, delicious projects, check out my
[GitHub](https://github.com/kauffecup) profile.

### Text RPG

![Slack Text RPG](/assets/images/projects/text-rpg.png)

This was a super fun project building a text rpg engine. My friend and I wanted
to create a multiplayer Slack game for our Slack team - he was the brains behind
the story and text, and I was the brains behind the code.

The engine supports multiplayer, battles, inventory management, map navigation,
conditional branching in the story, amongst other things. All the core code is
agnostic from the story - the engine simply requires configuration files for the
zones, monsters, items, etc. The engine is also agnostic of where it runs -
there is a super thin "adapter" interface that requires functions for
loading/saving data, and sending/receiving messages. Example adapters have been
supplied for slack, running locally in the terminal (for development), and
loading/saving the game state in different places.

Next steps are to write some kind of tool that automates the creation of the
configuration files (they can get rather complex and are prone to bugs
themselves), as well as some kind of tool for observing and manipulating game
state in real time.

[GitHub](https://github.com/kauffecup/text-rpg-engine).

### Musical Arrangement Database

![Slack Text RPG](/assets/images/projects/sage.png)

I "donated" this tool to my old group as a means to organize their arrangements.
The process involved migrating from physical drawers containing hundreds of pdfs
loosely alphabetized into a searchable, easy to use, online tool with super fun
metadata.

The database itself is written in CouchDB (a NoSQL db) and takes advantage of
its notions of views and its quick map reduce. The files themselves are stored
on backblaze for its combination of speed and cheapness.

The WebUI is a React/Redux app that was pretty fun to write.

[GitHub](https://github.com/kauffecup/hangovers-database).

### React Native + React Web Codesharing Hello World

React Native                              |  React Web
:----------------------------------------:|:-------------------------------------:
![react native](/assets/images/post-images/react-web-native-codesharing/mobile.gif) | ![react web](/assets/images/post-images/react-web-native-codesharing/web.gif)

I'm not gonna speak too much about this here as I already wrote a
[blog post about it](/react-web-native-codesharing/) (and also I've sort of
stopped maintaining it over the past few months - don't judge me too harshly).

The need to do this came up from an app I was building for work, and I ended up
building this example app to help explain myself during the resulting blog post.
While it ended up being a neat concept (and my most read post by far), I
recognize that very few applications will share enough logic between their web
and native apps for it to be applicable. Regardless, very fun!

[GitHub](https://github.com/kauffecup/react-native-web-hello-world).

## Work Projects _(that I'm allowed to share)_

There are some more, delicious, nutritious, projects that I've blogged about
but haven't included here. Guess that means you'll have to read
[my whole blog](/posts).

### Election Insights

![election insights](/assets/images/post-images/election-insights/app.png)

Again, not going to speak too much about this, as there is a post
[here](/election-insights). I was looking for a way to experiment with
visualizing different NLP data from different Watson services and ended up
building this visualization around the election (for topical reasons). It uses
React + D3 + Redux + MongoDB to do all of its magic. Unfortunately, the average
sentiment it picked up around different entities correctly predicted the 2016
election.

[GitHub](https://github.com/IBM-Bluemix/election-insights).

### Conversational Agent with Harman

![harman](/assets/images/projects/harman.png)

I discuss this more on my [about](/about) page, but I worked alongside a team of
four to create the server-side technology for IBM's
[partnership with Harman](https://www.youtube.com/watch?v=p5fOVNSQrS0) in
creating a physical conversational agent for different conversation and
automation scenarios. We constructed the conversational model, developed a means
for device interaction using voice, designed the database for storing user
metadata, and built an admin UI for testing, debugging, and device management.

### Verse

![verse](/assets/images/projects/verse.png)

I'd be remiss to not include my first project at IBM here. Verse is a single
page web application replacement of <s>Lotus</s> IBM Notes. It still uses the
same Domino backend as Notes, but creates its own SOLR index for speedy
searching. As I was there from when the team was only 5 people, I've had my
hands pretty much all over the app.

## Open Source Contributions

#### Node Backblaze

  - Fix reauthentication
    ([Pull Request](https://github.com/cebollia/node-b2/pull/1))

#### Cloud Foundry NodeJS Buildpack

  - Adding support for Yarn package manager
    ([Pull Request](https://github.com/cloudfoundry/nodejs-buildpack/pull/71))

#### Heroku Buildpack

  - Enhance yarn branch with rebuild logic
    ([Pull Request](https://github.com/heroku/heroku-buildpack-nodejs/pull/341))

#### React Select

  - Fix bug where user-typed-text gets lowercased
    ([Pull Request](https://github.com/JedWatson/react-select/pull/1329))

#### PokemonGoMap

  - Make application Cloud Foundry and Bluemix compatible
    ([Pull Request](https://github.com/AHAAAAAAA/PokemonGo-Map/pull/2383))
  - Add deployment instructions
    ([Pull Request](https://github.com/JonahAragon/PoGoMapWiki/pull/6))
  - Further enhance Cloud Foundry compatability
    ([Pull Request](https://github.com/JonahAragon/PokemonGo-Map/pull/3369))

#### IBM Bluemix Repo Guidelines

  - Add docs on OpenWhisk actions
    ([Pull Request](https://github.com/IBM-Bluemix/repo-guidelines/pull/3))

#### Watson Developer Cloud Node SDK

  - ReadMe enhancement
    ([Pull Request](https://github.com/watson-developer-cloud/node-sdk/pull/250))

#### IBM Message Hub (Kafka)

  - Add proper promise management to Node SDK
    ([Pull Request](https://github.com/ibm-messaging/message-hub-rest/pull/3))

#### Hubot

  - Add Cloud Foundry and Bluemix deployment instructions
    ([Pull Request](https://github.com/github/hubot/pull/1095))

#### React Native Chart

  - Enhance graph API with `tightBounds` prop
    ([Pull Request]( https://github.com/tomauty/react-native-chart/pull/35))
  - Add support for React Native 0.15.1
    ([Pull Request](https://github.com/tomauty/react-native-chart/pull/34))

#### Spotify Demo Auth Flow App

  - Enhance demo app to use Spotify node module instead of manually formatting
    requests
    ([Pull Request](https://github.com/spotify/web-api-auth-examples/pull/7))

#### Node Microphone

  - Fix compatibility with node > 0.11.x
    ([Pull Request](https://github.com/vincentsaluzzo/node-microphone/pull/12))
