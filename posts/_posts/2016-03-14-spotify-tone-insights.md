---
layout: post
title: "Spotify Tone Insights"
tags: [spotify, watson]
image: assets/images/post-images/spotify-tone-insights/header.jpg
description: >
  Use IBM Watson to analyze the tone of songs in your Spotify
  playlists. Music is cool and Spotify is rad and machine learning can
  be funny so why not mix 'em?
---

*TL;DR - I created an application that analyzes the lyrics in your
Spotify playlists using [IBM Watson Tone Analytics][ta]. Play with the
app [here][app]. Look at the code [here][git]. Run it yourself locally
or deploy it by following [these instructions][git].*

Before we get in too deep, you might want to read [this other
post][sblog]... consider it a "part 1." It explains setting up the auth
flow with a [Node][n] + [React][r] + [React-Router][rr] + [Redux][rx]
app. This post will only discuss integrating [Watson Tone Analytics][ta]
into an already authenticated application.

We're going to be digging through an app that digs through your music.
The app fetches song lyrics, sends them off to some
fun-machine-learning-tone-analytics-algorithm and then visualizes the
data in the UI. Tone analytics is a service that was trained on a bunch
of Twitter data to determine if text is sad or angry or joyful etc.
We'll start with a high level overview of what's going on, and then
discuss key code snippets that power the more crucial parts of the
application. Again, the app is [here][app], and the code is [here][git]
if you want to play around with either before finishing this post.

{% include ad-blog.html %}

## ...why do this at all?

This is a question I ask myself often when throwing together tiny apps
like this one. Honestly, the motivation behind this doesn't stem much
beyond it being fun. Music is cool and Spotify is rad and machine
learning can be funny so why not throw them all together?

Just check out these results:

![architecture](/assets/images/post-images/spotify-tone-insights/screenshot.png)

...pretty fun, right?

To use [the app][app], simply log in and click on a playlist! That's it!
[Watson][ta] gives us percentiles for the emotions found in Pixar's
*Inside Out* - Joy, Sadness, Anger, Disgust, and Fear. Once all your
results are in you'll be able to sort a metric by clicking on its
header.

## Architecture

![architecture](/assets/images/post-images/spotify-tone-insights/architecture.png)

In this app, our Node server handles the [Spotify Authentication
Workflow][sblog], as well as gathering the lyric information and caching
them in [Cloudant][cd]. Once our client is authenticated, it uses its
access token to query Spotify directly to load the playlist and track
information. When the user loads a playlist, the client fires off
requests to the node server, where it gathers the lyrics and then shoots
them off to [Watson][ta] for some tone analytics.

### Getting the Lyrics

This turned out to be one of the trickiest parts of this whole
operation; it's shockingly difficult to acquire song lyrics... legally.
I ended up using [Musixmatch][mx]'s "free tier." With their API key
you can request 500 lyrics per day and obtain a whopping 30% of the
song. Their terms of service also allows you to cache lyrics, so that's
a big plus.

Our flow then, as detailed in the architecture diagram above is:

  1. See if we already have the lyrics in our [Cloudant][cd] cache
  1. If it's there... great! Use it!
  1. If not, fetch the lyrics from [Musixmatch][mx], return those and
     put the results in our cache
     
The code for this looks like (*from [`server/routes.js`][rts]*):

~~~js
function getLyrics(track, artist, album) {
  return cloudant.get(track, artist, album).then(body => {
    return body.lyrics;
  }, e => {
    if (e.error === 'not_found') {
      return matchSong(track, artist, album)
        .then(id => getLyricsFromMusixMatch(id))
        .then(lyrics => {
          cloudant.insert(track, artist, album, lyrics);
          return lyrics;
        });
    } else {
      throw e;
    }
  });
}
~~~

Now this does mean that we're performing the [tone analytics][ta] on
only the first 30% of each song, but hey, at least we're doing it
legally.

Getting lyrics from [Musixmatch][mx] is as simply as hitting their
`/matcher.track.get` endpoint to get the song id, and then hitting 
`/track.lyrics.get` to get the lyrics so I'm not going to go into that
here.

### Getting the Tone

I go a little more in depth into using the [Watson Tone Analytics][ta]
API in my [Ambient Sentiment][as] post, so be sure to check that out.
NPM makes our life a little easy here and our asynchronous tone fetching
function looks like (*from [`server/routes.js`][rts]*):

~~~js
const watson = require('watson-developer-cloud');
const toneAnalyzer = watson.tone_analyzer(opts);
function toneAsync(text) {
  return new Promise((resolve, reject) => {
    toneAnalyzer.tone({ text }, (e, tone) => {
      if (e) {
        reject(e);
      } else {
        resolve(tone);
      }
    });
  });
}
~~~

### Putting it All Together

All our endpoint needs to do is get the lyrics and then feed the lyrics
to Watson (he's a growing boy and needs his veggies) (*from
[`server/routes.js`][rts]*):

~~~js
router.get('/tone', (req, res) => {
  const { track, artist, album } = req.query;
  getLyrics(track, artist, album).then(lyrics => {
    return toneAsync(lyrics);
  }).then(tone => {
    res.json(tone);
  }).catch(e => {
    res.status(500);
    res.json(e);
    console.error(e);
    console.error(e.stack);
  });
});
~~~

### Client Code

The only thing I want to call out client-code-wise, apart from what I
already blogged about in "[part 1: authentication town][sblog]," is how
the client loads a single playlist and gets each track's tone
information.

What's happening here is we first issue the `getPlaylist` call from
our `spotifyApi` module.

A quick tangent; our `spotifyApi` friend is initialized via:

~~~js
import Spotify from 'spotify-web-api-js';
const spotifyApi = new Spotify();
~~~

And then, as detailed in [my other post I keep bringing up][sblog], the
access token get's set during our authentication workflow:

~~~js
spotifyApi.setAccessToken(accessToken);
~~~

{% include ad-blog.html %}

Ok, so, once we have the tracks from `spotifyApi.getPlaylist()`, we make
requests for each tracks tone information. We do this by hitting the
`/tone` endpoint with the tracks name, album, and artist info (*from
[`client/actions/actions.js`][acts]*):

~~~js
export function loadPlaylist(userID, playlistID) {
  return dispatch => {
    dispatch({ type: TRACK_LIST_BEGIN });
    spotifyApi.getPlaylist(userID, playlistID).then(data => {
      dispatch({ type: TRACK_LIST_SUCCESS, data });
      data.tracks.items.map(i => {
        const t = i.track;
        return asyncGet('/tone', {
          track: t.name,
          artist: t.artists.map(a => a.name).join(', '),
          album: t.album.name
        }).then(({ body }) => dispatch({
          type: TRACK_LIST_TONE,
          id: t.id,
          tone: body.document_tone.tone_categories,
          playlistID
        })).catch(error => {
          dispatch({ type: TRACK_LIST_TONE_ERROR, error, playlistID, id: t.id });
        });
      });
    }).catch(error => {
      dispatch({ type: TRACK_LIST_FAILURE, error });
    })
  }
}
~~~

## Crumbling Cookies

There we have it, another nice, sweet, and deliciously tasty mini-app.
In case you skipped all the way to the end (because it's 2016 and who
reads instead of skimming) here are some fun links:

  - [The app we've been talking about the whole time][app]
  - [The code for the app we've been talking about the whole time][git]
  - [My blog post on Spotify's Authentication workflow with React +
    React-Router][sblog]
  - [My blog post on "Ambient Sentiment" and using Watson Tone
    Analytics][as]
  - [Watson Tone Analytics][ta]
  - [Musixmatch developer stuff][mx]
  - [Spotify developer stuff][sag]

[app]:   http://spotifyinsights.mybluemix.net
[git]:   https://github.com/kauffecup/spotify-tone-insights
[ta]:    http://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/tone-analyzer.html
[sblog]: /spotify-auth-react-router
[as]:    /ambient-sentiment
[mx]:    https://developer.musixmatch.com/
[sag]:   https://developer.spotify.com/web-api/authorization-guide/
[cd]:    https://cloudant.com/
[rr]:    https://github.com/rackt/react-router
[rrr]:   https://github.com/rackt/react-router-redux
[r]:     https://facebook.github.io/react/
[rx]:    http://redux.js.org/
[n]:     https://nodejs.org
[rts]:   https://github.com/kauffecup/spotify-tone-insights/blob/master/server/routes.js
[acts]:  https://github.com/kauffecup/spotify-tone-insights/blob/master/client/actions/actions.js