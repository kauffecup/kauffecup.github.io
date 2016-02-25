---
layout: talk
title: "Dismantling the Monolith"
location: "NodeJS Boston"
locationURL: "http://www.meetup.com/Node-JS-Boston/events/228609581/"
gitHub: "https://github.com/kauffecup/monolith-microlith"
slidr: "https://slidr.io/kauffecup/dismantling-the-monolith"
dataCardKey: c7eb2be95ffc4d709de201b870895b9b
tags: [node, microservices]
abstract: >
  Microservices seem to be all that anyone is talking about these days; long
  gone is the monolithic app. The idea is simple - take one large app and break
  it into a bunch of tinier apps that interact in a reliable and fault-tolerant
  way. This brings with it a new set of functional and technical challenges to
  overcome - how do these "tiny apps" communicate? How do they discover each
  other? How big is too big? In this talk, we will build a microservice-based
  architecture up from scratch, while discussing different design patterns and
  common pitfalls, all in Node.js.
---

In the first demo, we live coded and deployed the app under the `monolithic`
directory in the GitHub repo. We then deployed the app to Bluemix, scaled up
the number of instances and demonstrated how poorly the "monolithic"
architecture scales.

In the second demo, we live coded and deployed the app under the `microservices`
directory in the GitHub repo. While this isn't a truly, authentically,
organically, artisanal microservices application, it was designed to get the
point across. When deployed with multiple instances, this application scales
just beautifully. To make it truly utilize microservices we would have had a
different service for our web client and one for our messaging and maybe one
for managing client requests.
