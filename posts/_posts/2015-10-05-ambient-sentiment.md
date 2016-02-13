---
layout: post
title: "Ambient Sentiment"
tags: [watson, slack]
image: assets/images/post-images/ambient-sentiment/header.jpg
description: >
  A fun little example combining a blink(1) with IBM Watson and Slack to
  visualize the sentiment of incoming messages in real time.
---

Last week I picked up a [blink(1)](https://blink1.thingm.com/) at a conference,
and had a lot of fun with it. It's a pretty simple little device that can
conjure up any color that can be described via RGB. Naturally, I decided to hook
it up to IBM Watson's [Tone
Analyzer](https://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/tone-analyzer.html)
in order to visualize the sentiment of my Slack channel in real time.

*Don't worry, after these pictures there will be a lot of code, and if you want
to jump straight into it [find it/fork it on
github](https://github.com/kauffecup/blink1-sentiment).*

Whenever someone messages something angry, the blink(1) turns red:

![angry](/assets/images/post-images/ambient-sentiment/angry.jpg)

...or when they say something happy it turns yellow:

![happy](/assets/images/post-images/ambient-sentiment/happy.jpg)

...or when they say something sad it turns blue:

![sad](/assets/images/post-images/ambient-sentiment/sad.jpg)

...and all shades in between.

Watson gives us values of 0 - 1 for the following nine sub-categories from the
following three categories:

  - Emotional Tone: cheerfulness, negative, and anger Writing Tone: analytical,
  - confident, and tentative Social Tone: openness, agreeableness,
  - conscientiousness

We'll do our best to construct RGB values from these... more on that later.

Of course, this doesn't have to be hooked up to Slack, but can be applied to any
real time stream of text. It would be interesting to see a visualization in real
time of a Twitter feed, or the comments on a blog, or maybe even the captions on
a TV. And hey, if you have access to a good Speech to Text service ([like this
one from
Watson](https://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/speech-to-text.html)),
that could get pretty interesting too.

## let's dive into the code, shall we?

#### (of course it's a node app)

First we have all of our imports:

~~~js
import Blink1    from 'node-blink1';
import Promise   from 'bluebird';
import toneAsync from './toneAsync';
import Slack     from 'slack-client';
import fs        from 'fs';
~~~

And then we define a few constants:

~~~js
// the token we'll use to authenticate w/ slack
const SLACK_TOKEN = process.env.SLACK_TOKEN || fs.readFileSync('./SLACK_TOKEN.txt', 'utf8');
// Automatically reconnect after an error response from Slack
const AUTO_RECCONECT = true;
// Automatically mark each message as read after it is processed
const AUTO_MARK = true;
// the time it takes to fade da blinker's colorz
const FADE_TIME = 1000;
~~~

Once that's taken care of, we initialize the blink(1):

~~~js
var blink = Promise.promisifyAll(new Blink1());
blink.off();
blink.setRGB(0, 0, 0);
~~~

*The RGB value has to be set in order for the `fadeToRGB` method (used later in
*the code) to work. This is why we initialize it to (0,0,0).*

And initialize Slack (or wherever we want to get our real time data from):

~~~js
var slack = new Slack(SLACK_TOKEN, AUTO_RECCONECT, AUTO_MARK);
slack.on('open', () => {
  console.log(`Connected to ${slack.team.name} as @${slack.self.name}`);
});
slack.on('message', ({text}) => {
  console.log(`analyzing "${text}" ...`);
  textToColor(text);
});
slack.on('error', e => {
  console.error(e);
});
slack.login();
~~~

We now need to stream our data to Watson and then set the blink(1)'s color based
on the response. That's what is happening in `slack.on('message', ...)`, it
passes the real time Slack text to our `textToColor(text)` method (where the
magic happens):

~~~js
// go off to Watson with some text and then set blink(1)s color based on the response
function textToColor(text) {
  toneAsync(text).then(({children: [
    {children: [{normalized_score: cheerfulness}, {normalized_score: negative}, {normalized_score: anger}]},
    {children: [{normalized_score: analytical}, {normalized_score: confident}, {normalized_score: tentative}]},
    {children: [{normalized_score: openness}, {normalized_score: agreeableness}, {normalized_score: conscientiousness}]}
  ]}) => {
    // cheerfulness, negative, and anger are emotional tone
    // analytical, confident, and tentative are writing tone
    // openness, agreeableness, conscientiousness are social tone

    // cheerfulness, and confident contribute to yellow (...conscientiousness?)
    // negative, and tentative contribute to blue  (...analytical?)
    // anger contributes to red
    // openness, and agreeableness contribute to green (?)
    var y = (cheerfulness + confident + conscientiousness)/3 * 255;
    var r = Math.max(anger * 255, y);
    var g = Math.max((openness + agreeableness)/2 * 255, y);
    var b = (negative + tentative + analytical)/3 * 255;

    return blink.fadeToRGBAsync(FADE_TIME, r, g, b);
  }).catch(e => console.error(e));
}
~~~

As you can see by my uncertainty in the comments, figuring out how to map
Watson's response to RGB values proved to be rather... difficult. With this
current configuration, Taylor Swift's "Blank Space" renders pink, Coldplay's
"The Scientist" renders blue, and Rage Against the Machine's "Killing in the
Name of" render's red... which feels right.

This is definitely the place that could use the most improvement. Should we
scale our RGB values up such that one is always at 255 so that the blink(1) is
always bright? Should we not only have certain traits contribute to values but
have lack of traits contribute to other values - i.e. lack of confidence
contributing to blue? Should "analytical" really contribute to blue and should
"conscientiousness" really contribute to yellow? Should we define more preset
colors for certain results?

By the way, the `toneAsync` method is just a wrapper around the `toneAnalyzer`
methods from the `watson-developer-cloud` [module on
npm](https://www.npmjs.com/package/watson-developer-cloud):

~~~js
import Promise from 'bluebird';
import watson  from 'watson-developer-cloud';

// build the credentials object from vcap services
var vcapServices = process.env.VCAP_SERVICES ? JSON.parse(process.env.VCAP_SERVICES) : require('./VCAP_SERVICES.json');
var toneCredentials = vcapServices.tone_analyzer[0].credentials;
toneCredentials.version = 'v2';

// initialize the tone analyzer
var toneAnalyzer = watson.tone_analyzer(toneCredentials);

// our export function. takes in text and returns a promise that resolves with
// the response from watson.
export default text => new Promise((resolve, reject) => {
  toneAnalyzer.tone({text: text}, (e, res, request) => {
    if (e) {
      reject(e);
    } else {
      resolve(res);
    }
  })
});
~~~

I defined this in a separate file just to keep my main file cleaner... but that
isn't necessary.

## a few notes

To run the code yourself, you'll need an [IBM Bluemix](https://bluemix.net) and
the [Tone
Analyzer](https://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/tone-analyzer.html)
service bound to a Node.js runtime.

I used [bluebird](https://github.com/petkaantonov/bluebird)'s awesome
`Promise.promisifyAll` method when initializing the blink(1). This adds async
methods for all methods that take a callback as the last argument. These async
methods returns a promise instead of taking a callback.

For example, in the code above I made use of `fadeToRGBAsync` instead of the
`fadeToRGB` method defined [in the npm module for
blink1](https://www.npmjs.com/package/node-blink1). These could be chained like
this:

~~~js
blink.fadeToRGBAsync(FADE_TIME, r1, g1, b1).then(() =>
  blink.fadeToRGBAsync(FADE_TIME, r2, g2, b2)
).then(() =>
  blink.fadeToRGBAsync(FADE_TIME, r3, g3, b3)
).then(() =>
  blink.fadeToRGBAsync(FADE_TIME, r4, g4, b4)
).then(() =>
  blink.fadeToRGBAsync(FADE_TIME, r5, g5, b5)
).catch(console.error);
~~~

To run the app, you have to use babel (or perhaps Node v4 but I haven't tried
that yet):

~~~bash
babel-node app.js
~~~

And again, the codebase can be found [here on
github](https://github.com/kauffecup/blink1-sentiment), if you want to run this
yourself.
