---
layout: post
title: "Ambient Sentiment pt. 2"
tags: watson
image: assets/images/post-images/ambient-sentiment-2/header.jpg
description: >
  Visualizing tone in real time with a bit of websockets fun throne in.
---

*TL;DR - Here's a fun app that converts inputted tone into color. It uses
websockets to keep all the clients in sync so you're seeing and contributing
to a shared experience. The code is available [here][gh] and the app is hosted
[here][app].*

In the interest of having a light-spritied demo today, let's hook up Watson's
[Tone Analyzer][ta] to some websockets. Why? Well, "why not" is a much better
question. Here's a gif if you still need some convincing:

![app gif](/assets/images/post-images/ambient-sentiment-2/app.gif)

Play with the app yourself [here][app].

{% include ad-blog.html %}

This sort of picks up where [Ambient Sentiment](/ambient-sentiment) left off,
and by "sort of" I mean it reuses a majority of the same code for converting
the results of the Watson Tone Analysis into color. Rather than rendering the
color on an external piece of hardware, we're creating inter-client
communication allowing each user to see what everyone else is analyzing.

## watson tone

Using the [Watson Tone][ta] API we get information about the social tone,
emotional tone, and writing tone of a given piece of text. We can use this
to determine joy or anger or sadness or confidence or disgust or tentativeness
or...

The challenge that we face is how do we convert that into color? We'll discuss
this more when we look at the code down below, but essentially we map different
tone categories to different factors in an rgb measurement. Then, when all is
said and calculated, we end up with a unique color for a given sentence.

## taking a step back...

What's actually going on here?

The app itself only consists of two files, and is essentially a variation on
[socket.io][si]'s hello world chat app. All we have is [`server.js`][sjs] and
[`index.html`][ix]. It's rather exciting when the entirety of the code for a
demo can be discussed in a single blog post.

[Here][gh]'s a link to the GitHub repo.

### `server.js`

_full code available [here][sjs]_

Before we get too into some nitty-gritties, let's get the set up out of the way.
First we have to include our modules...

~~~js
const app = require('express')();
const server = require('http').Server(app);
const io = require('socket.io')(server);
const toneAnalyzer = require('watson-developer-cloud').tone_analyzer({
  username: '<username>',
  password: '<password>',
  version: 'v3-beta',
  version_date: '2016-05-19'
});
~~~

Then we do some fun node server setup things...

~~~js
app.set('port', process.env.PORT || 3000);
app.get('/', (req, res) => {
  res.sendFile(`${__dirname}/index.html`);
});
server.listen(app.get('port'), () => {
  console.log(`listening on ${app.get('port')}`);
});
~~~

Ok, now for the fun part. We're going to set up our websocket to create a
connection with our clients, and when it receives "tone messages" it will
shoot those off to Watson, calculate the color, and send the original string
along with the corresponding color to every client with an open connection.
Sounds rather tricky, but using the magic of socket.io it's only 13 lines of
code:

~~~js
io.on('connection', socket => {
  socket.on('tone message', text => {
    toneAnalyzer.tone({ text }, (err, tone) => {
      if (err) {
        console.error(err);
      } else {
        io.emit('tone', {
          text,
          color: calculateColor(tone)
        });
      }
    });
  });
});
~~~

The real meat and taters part of what's going on here is the `calculateColor`
method. It is definitely borrowed from [Ambient Sentiment pt. 1](/ambient-sentiment)
and has only been tweaked to support v3 of the watson API.

Please pardon the gross abuse of object destructuring in the argument of the
function.

~~~js
function calculateColor({document_tone: { tone_categories: [
  {tones: [{score: anger}, {score: disgust}, {score: fear}, {score: joy}, {score: sadness}]},
  {tones: [{score: analytical}, {score: confident}, {score: tentative}]},
  {tones: [{score: openness}, {score: conscientiousness}, {score: extraversion}, {score: agreeableness}, {score: range}]}
]}}) {
  const y = (joy + confident + conscientiousness)/3 * 255;
  const r = Math.max((anger + fear)/2 * 255, y);
  const g = Math.max((openness + agreeableness + disgust)/3 * 255, y);
  const b = (sadness + tentative + analytical)/3 * 255;
  return `rgb(${Math.round(r)},${Math.round(g)},${Math.round(b)})`;
}
~~~

So what's happening here is we're saying that joy and confidence contribute to
yellow, sadness and tentativeness and analytics contribute to blue, anger and
fear contribute to red, openness agreeableness and disgust contribute to green.
This is by no means perfect, but it sort of gets the job done.

{% include ad-blog.html %}

### `index.html`

_full code available [here][ix]_

Just for completion sake, here's what our DOM looks like:

~~~html
<div id="tone-visualizer">
  <div id="current-text"></div>
  <form action="" id="form">
    <input id="m" autocomplete="off" />
    <button>Send</button>
  </form>
</div>
~~~

We also need to include the socket.io client code:

~~~html
<script src="/socket.io/socket.io.js"></script>
~~~

For our js we start by initializing our socket and getting reference to key
DOM elements. We will not be using JQuery because we are badasses so we
do this up here to make our following code more concise.

~~~js
var socket = io();
var form = document.getElementById('form');
var input = document.getElementById('m');
var currentText = document.getElementById('current-text');
var toneVisualizer = document.getElementById('tone-visualizer');
~~~

Ok, so now, when a user submits our form. We're going to emit that on the
"tone message" topic over our websocket, and clear what was in the input:

~~~js
form.addEventListener('submit', function(e) {
  e.preventDefault();
  socket.emit('tone message', input.value);
  input.value = '';
  return false;
});
~~~

When we receive the tone-text and tone-color, we set the text in our page and
set the background color accordingly:

~~~js
socket.on('tone', function(msg) {
  currentText.innerText = msg.text;
  document.body.style.background = msg.color;
});
~~~

## and so it goes

Believe it or not, the entire demo codebase including comments and html and
css is only 110 lines. It's pretty exciting. Again, be sure to check out the
[GitHub Repo][gh] and play with [the app][app] itself.

[app]: http://realtimetone.mybluemix.net/
[ta]:  http://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/tone-analyzer.html
[si]:  http://socket.io
[sjs]: https://github.com/kauffecup/realtime-tone/blob/master/server.js
[ix]:  https://github.com/kauffecup/realtime-tone/blob/master/index.html
[gh]: https://github.com/kauffecup/realtime-tone/
