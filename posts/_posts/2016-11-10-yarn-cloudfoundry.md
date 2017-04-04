---
layout: post
title: "Using Yarn with Cloud Foundry"
tags: [yarn, cloud-foundry, bluemix]
description: >
  Using Yarn instead of NPM for the Cloud Foundry Buildpack
---

The pull request for everything discussed in this post can be found [here][pr].

[Yarn][yn] is an awesome package manager. Don't believe me? Ask the dishes.

We all thought [npm][npm] was the cool kid on the block, taking JavaScript and
node from 0 to 100 overnight, but BOY WERE WE WRONG. I kid, I kid. npm really
is pretty great, it is perhaps the most used package manager for any language
and may be responsible for JavaScript being the most used language on GitHub
(please don't quote me on any of this).

[npm][npm], however, isn't without its flaws. These are covered extensively in
Facebook's [introducing Yarn][iyn] post, but I might as well mention the two
main ones in an uber paraphrased fashion in this post.

### 1. Speed.

[Yarn][yn] simply blows [npm][npm] out of the water for installation speed on
entire package dependencies. There's a pretty thorough speed comparison
[here][ync], and if you don't believe it, I recommend trying locally yourself.
We're talking download speeds that take about 1/3 - 1/4 as less the amount of
time, crazy stuff.

### 2. Reliability.

[Yarn][yn] is more reliable and deterministic than [npm][npm]. It uses a a
"detailed but concise" lockfile to guarantee that the same install works the
exact same way on different systems. [npm][npm] installs can have race
conditions on full package installs; installing packages in different orders can
result in different versions of different packages being installed, causing
pretty nasty bugs. This lockfile guarantees the exact same install from machine
to machine. Yay!

## ok, on to Cloud Foundry

Without making this a long-winded post about Cloud Foundry, Cloud Foundry is an
open-sourced platform as a service. You can deploy your apps all willy-nilly
simply by defining a `manifest.yml` config file that defines fun things about
your app. The part we're going to focus on today is the buildpack. Here's what
an example manifest looks like:

~~~yml
applications:
- buildpack: https://github.com/kauffecup/nodejs-buildpack.git#yarn
  command: npm run start
  path: .
  instances: 1
  memory: 512M
~~~

You may notice it's already using my yarn buildpack ;)

From the [Cloud Foundry docs on buildpacks][cfb], "Buildpacks provide framework
and runtime support for your applications. Buildpacks typically examine
user-provided artifacts to determine what dependencies to download and how to
configure applications to communicate with bound services." Here is
[a list of first and third party buildpacks][cfbs]. Buildpacks are simply a
collection of three simple shell scripts: `detect`, `compile`, and `release`.

### detect

The platform uses the `detect` script to figure out what buildpack to use for
an app if none is specified. For example, the node one is as simple as:

~~~sh
#!/usr/bin/env bash
# bin/detect <build-dir>

BP=$(dirname "$(dirname $0)")
if [ -f "$1/package.json" ]; then
  echo "node.js "$(cat "$BP/VERSION")""
  exit 0
fi

exit 1
~~~

For the rest of the post, we're going to extend the existing
[Node buildpack][nbp] to use [Yarn][yn] instead of [npm][npm] if it detects the
presence of that lockfile we discussed up top.

### compile

Compile is sort of where the money happens. It's responsible for pulling in any
dependencies, building your code, and all that fun stuff.


[cf]:   https://www.cloudfoundry.org/
[cfb]:  https://docs.cloudfoundry.org/buildpacks/
[cfbs]: https://github.com/cloudfoundry-community/cf-docs-contrib/wiki/Buildpacks
[nbp]:  https://github.com/cloudfoundry/nodejs-buildpack
[npm]:  https://npmjs.org/
[pr]:   https://github.com/cloudfoundry/nodejs-buildpack/pull/71
[iyn]:  https://code.facebook.com/posts/1840075619545360
[yn]:   https://yarnpkg.com/
[ync]:  https://yarnpkg.com/en/compare
