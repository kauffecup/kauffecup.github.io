---
layout: post
title: "Spotify Auth + React Router = yumm."
tags: [spotify, react, node]
image: assets/images/post-images/spotify-react/header.jpg
description: >
  Example application demonstrating authentication flow through Spotify's Web
  API with React and React Router.
---

*TL;DR: Here's how to set up an application that authenticates and use's
[Spotify's Web API][sgs] with [React][r] and [React Router][rr]. The full repo
is [here (yay code!)][gh].*

This demo shows how to access Spotify's apis both [from node][swn] and [from
the web client][swj].

## motivation.

I've been working on a super fun awesome [Spotify][s] + [IBM Watson][wat] app,
and ran into some fun times dealing with [Spotify's Authorization][sag]. Once
I inevitably post about that, I wouldn't want that post to get bogged down
authentication details... so here we are; a nice, standalone post that I'll be
able to point to, and say "here! here's how ya do it!"

This example is essentially a variation on the `authorization_code` demo from
Spotify's [Web Auth Examples][wae]. The main difference is the client code;
whereas their example is contained in one `index.html` file, this example shows
how to do the same thing with [React][r] and [React-Router][rr]. Of course there
any many benefits to [React][r] that we're not going to get in to here, so just
trust me that we want to use it ;)

The other difference is the updated server code. Instead of using `request`
directly (and XHR in the browser), this example interfaces with Spotify through
the [Spotify Web API Node Module][swn] (and [Spotify Web Api Client][swj] in the
browser). It also uses fun ES6 goodness. I opened a [pull request][spr] with
them to update their server code to what you see here. Who knows if that'll
ever get merged in!

## let's get to it.

We'll be building the app in [this repo][gh]. It's pretty fun!

![Spotify Auth App](/assets/images/post-images/spotify-react/login-page.png)


Make sure to read through [Spotify's Getting Started Guide][sgs] if this is your
first time using the Spotify API. After you've created your application and have
your client id and client secret, make sure to add
`http://localhost:3000/callback` to your Redirect URIs:

![Redirect URI](/assets/images/post-images/spotify-react/redirect-uri.png)

We'll be using that information to initialize our `spotifyApi` client (in
[`server/routes.js`][rts]):

~~~js
const Spotify = require('spotify-web-api-node');
const spotifyApi = new Spotify({
  clientId: CLIENT_ID,
  clientSecret: CLIENT_SECRET,
  redirectUri: REDIRECT_URI
});
~~~

When the client hits our `/login` endpoint, we need to direct them to Spotify's
authorization URL. We achieve this via:

~~~js
router.get('/login', (_, res) => {
  const state = generateRandomString(16);
  res.cookie(STATE_KEY, state);
  res.redirect(spotifyApi.createAuthorizeURL(scopes, state));
});
~~~

This'll bring our user to Spotify's authorization page:

![Official Login](/assets/images/post-images/spotify-react/official-login.png)

Once they're authenticated, Spotify will send them back to whatever we specified
as the `redirectUri`, which in our case is `http://localhost:3000/callback`,
with an authorization code in the query. That endpoint will do validation,
retrieve the access and refresh token, and send this information to the client:

~~~js
router.get('/callback', (req, res) => {
  const { code } = req.query;
  spotifyApi.authorizationCodeGrant(code).then(data => {
    const { expires_in, access_token, refresh_token } = data.body;
    spotifyApi.setAccessToken(access_token);
    spotifyApi.setRefreshToken(refresh_token);
    res.redirect(`/#/user/${access_token}/${refresh_token}`);
  }).catch(err => {
    res.redirect('/#/error/invalid token');
  });
});
~~~

The actual code in [`server/routes.js`][rts] performs cookie validation before
calling the `authorizationCodeGrant` method above. We do that to make sure this
is the same user we sent off to [Spotify][s] to authenticate and not some
malicious villian. You may have noticed that in the `/login` endpoint, we set a
random string in the user's cookie that we called `state`. Spotify is going to
pass this back to us in a query argument so we can validate via:

~~~js
router.get('/callback', (req, res) => {
  const { code, state } = req.query;
  const storedState = req.cookies ? req.cookies[STATE_KEY] : null;
  // state state validation
  if (state === null || state !== storedState) {
    res.redirect('/#/error/state mismatch');
  } else {
    // the authorization code described above
    // ...
  }
});
~~~

So far, we've redirected our Client to two different roots, `/error` and,
`/user`. To have our client understand this, we're going to set up our roots in
the following way (from [`client/index.js`][idx]):

~~~js
class Root extends Component {
  render() {
    return (
      <Provider store={store}>
        <Router history={hashHistory}>
          <Route path="/" component={App}>
            <IndexRoute component={Login} />
            <Route path="/user/:accessToken/:refreshToken" component={User} />
            <Route path="/error/:errorMsg" component={Error} />
          </Route>
        </Router>
      </Provider>
    );
  }
}
~~~

This allows us to access the access token, refresh token, and error message in
our components via `this.props.params`. For example, our [error page
component][ec] is defined via:

~~~js
export default class Login extends Component {
  render() {
    // injected via react-router
    const { errorMsg } = this.props.params;
    return (
      <div className="error">
        <h2>An Error Occured</h2>
        <p>{errorMsg}</p>
      </div>
    );
  }
}
~~~

Which in turn will look like:

![Error Page](/assets/images/post-images/spotify-react/error-page.png)

*(there the url was `http://localhost:3000/#/error/Authentication Failed! Oh
noes!`)*

The user workflow is more complicated. As described above, our user gets
redirected to `/#/user/${access_token}/${refresh_token}` upon successful
authentication. Our [user component][uc] will take the access token and refresh
token, set them, and then request info from Spotify directly. Hence, when it
mounts...

~~~js
componentDidMount() {
  // params injected via react-router, dispatch injected via connect
  const {dispatch, params} = this.props;
  const {accessToken, refreshToken} = params;
  dispatch(setTokens({accessToken, refreshToken}));
  dispatch(getMyInfo());
}
~~~

Calling `getMyInfo` set's the user info in our application state via a dispatch.
The method is defined as (from our [`actions.js` file][acs]):

~~~js
import Spotify from 'spotify-web-api-js';
const spotifyApi = new Spotify();
export function getMyInfo() {
  return dispatch => {
    dispatch({ type: SPOTIFY_ME_BEGIN});
    spotifyApi.getMe().then(data => {
      dispatch({ type: SPOTIFY_ME_SUCCESS, data: data });
    }).catch(e => {
      dispatch({ type: SPOTIFY_ME_FAILURE, error: e });
    });
  };
}
~~~

And our [`reducer`][rdr] handle's the data via:

~~~js
// set our loading property when the loading begins
case SPOTIFY_ME_BEGIN:
  return Object.assign({}, state, {
    user: Object.assign({}, state.user, {loading: true})
  });

// when we get the data merge it in
case SPOTIFY_ME_SUCCESS:
  return Object.assign({}, state, {
    user: Object.assign({}, state.user, action.data, {loading: false})
  });
~~~

This allows us to render our User page...

![User Page](/assets/images/post-images/spotify-react/user-page.png)

## debrief.

That's it! By defining error and user pages, we can control what's displayed
in the client by routing it correctly from the server.

The client application structure is a simplified version of my [React + Redux +
Webpack Boilerplate][bp] for better ease of understanding. It can certainly be
awesome-ified (and maybe a little more complicated) by doing some of the fun
tricks in there.

My writeup in the `README` for [the GitHub repo][gh] goes much more in depth
as far as code structure and running the application are concerned - so be sure
to head on over there for even more good times. And who knows, maybe you'll fork
this bad boy and run it for yourself!

## further reading.

  - [The GitHub Repo][gh]
  - [Spotify's Getting Started Guide][sgs]
  - [Spotify's Web API Authorization Guide][sag]
  - [Spotify Web API Node][swn]
  - [Spotify Web API JS/Client][swj]
  - [Spotify's Web API Auth Exampls][wae]
  - [My Pull Request enhancing Spotify's examples][spr]
  - [React Router][rr]
  - [React Router Redux][rrr]
  - [React][r]
  - [Redux][rx]
  - [Better NPM Run][bnr]
  - [React + Redux + Webpack Boilerplate][bp]


[sgs]: https://developer.spotify.com/web-api/tutorial/
[sag]: https://developer.spotify.com/web-api/authorization-guide/
[swn]: https://github.com/JMPerez/spotify-web-api-node
[swj]: https://github.com/JMPerez/spotify-web-api-js
[wae]: https://github.com/spotify/web-api-auth-examples
[spr]: https://github.com/spotify/web-api-auth-examples/pull/7
[rr]:  https://github.com/rackt/react-router
[rrr]: https://github.com/rackt/react-router-redux
[r]:   https://facebook.github.io/react/
[rx]:  http://redux.js.org/
[bnr]: https://www.npmjs.com/package/better-npm-run
[bp]:  https://github.com/kauffecup/react-redux-webpack-boilerplate
[wat]: http://www.ibm.com/smarterplanet/us/en/ibmwatson/
[s]:   https://www.spotify.com/
[gh]:  https://github.com/kauffecup/spotify-react-router-auth
[rdr]: https://github.com/kauffecup/spotify-react-router-auth/blob/master/client/reducers/index.js
[acs]: https://github.com/kauffecup/spotify-react-router-auth/blob/master/client/actions/actions.js
[uc]:  https://github.com/kauffecup/spotify-react-router-auth/blob/master/client/components/User.js
[ec]:  https://github.com/kauffecup/spotify-react-router-auth/blob/master/client/components/Error.js
[idx]: https://github.com/kauffecup/spotify-react-router-auth/blob/master/client/index.js
[rts]: https://github.com/kauffecup/spotify-react-router-auth/blob/master/server/routes.js
