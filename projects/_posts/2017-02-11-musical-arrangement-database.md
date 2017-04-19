---
layout: post
title: "Musical Arrangement Database"
tags: [couchdb, cloudant]
description: >
  A CouchDB implementation with web UI for working with, searching for, and
  maintaining PDFs and finale files for arrangements.
---

![Musical Arrangement Database](/assets/images/projects/sage.png)

I "donated" this tool to my old group as a means to organize their arrangements.
The process involved migrating from physical drawers containing hundreds of pdfs
loosely alphabetized into a searchable, easy to use, online tool with super fun
metadata.

The database itself is written in CouchDB (a NoSQL db) and takes advantage of
its notions of views and its quick map reduce. The files themselves are stored
on backblaze for its combination of speed and cheapness.

The WebUI is a React/Redux app that was pretty fun to write.

[GitHub](https://github.com/kauffecup/hangovers-database).
