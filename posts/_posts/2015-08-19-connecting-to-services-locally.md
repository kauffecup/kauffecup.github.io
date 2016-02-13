---
layout: post
title: "Connecting to Bluemix Services Locally"
tags: bluemix
description: >
  How to connect to IBM Bluemix (or any Cloud Foundry provider) services when
  running your development environment.
---

When developing, it's nice to run locally and connect to the same services and
backends you'll be using in production (instead of faking data or responses).
The goal is to abstract out the differences between accessing them on Bluemix
and accessing them locally.

Here is an easy way to do that without using a proxy and without updating your
local environment variables for every different project you're working on.

**Note: this post is specific to using the Node.js runtime, but the same
technique can be applied to other runtimes.**

If you navigate over to your environment variables for a given application in
Bluemix, you'll see something like:

~~~js
{
  "user-provided": [
    {
      "name": "AlchemyAPI-2e",
      "label": "user-provided",
      "credentials": {
        "apikey": "YOUR_KEY"
      }
    }
  ],
  "mongolab": [
    {
      "name": "MongoLab-bh",
      "label": "mongolab",
      "plan": "sandbox",
      "credentials": {
        "uri": "mongodb://username:password@host.mongolab.com:port/db"
      }
    }
  ]
}
~~~

When developing locally, I like making a `VCAP_SERVICES.json` file that is
identical. I then make a `vcapServices.js` node module that looks like:

~~~js
var vcapServices;
// if running in Bluemix, use the environment variables
if (process.env.VCAP_SERVICES) {
  vcapServices = JSON.parse(process.env.VCAP_SERVICES);
// otherwise use our JSON file
} else {
  try {
    vcapServices = require('./VCAP_SERVICES.json');
  } catch (e) {
    console.error(e);
  }
}
module.exports = vcapServices;
~~~

This abstracts out the differences between running in Bluemix and running
locally. To reference your credentials for different services, all you need to
do is load in this module and use it like a JSON object.

For example, to connect to MongoLab...

~~~js
import mongoose     from 'mongoose';
import vcapServices from './vcapServices';

var mongoUri = vcapServices.mongolab[0].credentials.uri;
mongoose.connect(mongoUri);
~~~

Just make sure to add `path/to/VCAP_SERVICES.json` to both your `.gitignore` and
`.cfignore`!
