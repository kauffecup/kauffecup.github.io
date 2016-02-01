---
layout: post
title: "Simplify Your Node App"
tags: node
---

I used to be a believer in the monolithic Node App; a single place housing all
of the code your application will ever need; server-side and client-side alike.
While this genuinely can be great for tinier web apps (and is something I will
continue to do) it just doesn't scale.

## Split Up Your Client and Server Code

Yes, I know that they probably are using a library or two in common. Yes, I
understand that it's convenient to run `npm start` and have that kick off both
your server and build your client bundle. But there are things that you can't do
with the singular monolithic project.

## ...like what?

When your node app is just a collection of APIs and RESTful endpoints, you can
have multiple clients interacting with it - web, mobile, you name it. In the
most recent project I was working on, we had two different web UIs and a native
mobile app interacting with and getting data from the same node server. The web
clients, then, are just static files being served from a static file server.

Without separating the client and server code into separate projects, that would
not have been possible.

Just to reiterate (in case you skimmed that first paragraph) - the main
advantage here is that you can have multiple clients powered by the same
backend. This simplifies both your backend and frontend code. Maintainability is
key!

## Ok... so how?

Using [IBM Bluemix](https://bluemix.net) or a comparable Cloud Platform (Heroku,
Google App Engine, etc.), simply create multiple projects. One will be a node
app that runs `Project Endpoints` (for lack of a better name) and the others
will be your static file servers.

For the web apps, you can set up a [deployment
pipeline](http://www.jkaufman.io/bluemix-github-devops-integration/) that will
bundle your client code and update your static files.

Your clients just need to hit your `Project Endpoints` node server to get shared
backend goodness.

## Further Reading

  - [Cloud Foundry static file
    buildpack](https://github.com/cloudfoundry/staticfile-buildpack.git)
  - [Setting up a Bluemix Deployment
    Pipeline](http://www.jkaufman.io/bluemix-github-devops-integration/)
  - [Deplying Static Websites on
    Bluemix](https://developer.ibm.com/bluemix/2014/08/29/deploying-static-web-sites/)
