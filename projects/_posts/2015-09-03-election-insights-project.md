---
layout: post
title: "Election Insights Application"
tags: [watson, alchemy, mongodb]
description: >
  An app that analyzes and visualizes news about the election in real time.
---

![election insights](/assets/images/post-images/election-insights/app.png)

Again, not going to speak too much about this, as there is a post
[here](/election-insights). I was looking for a way to experiment with
visualizing different NLP data from different Watson services and ended up
building this visualization around the election (for topical reasons). It uses
React + D3 + Redux + MongoDB to do all of its magic. Unfortunately, the average
sentiment it picked up around different entities correctly predicted the 2016
election.

[GitHub](https://github.com/IBM-Bluemix/election-insights).
