---
layout: post
title: "Election Insights"
tags: [watson, alchemy, mongodb]
image: assets/images/post-images/election-insights/header.jpg
description: >
  The 'how' and 'why' between building an app that analyzes and visualizes news
  about the election in real time. It uses React + D3 for the visualization.
---

Let's talk about the election, shall we?

I made [an app](http://electioninsights.mybluemix.net/) that analyzes and
visualizes what's being talked about related to the election and draws some
pretty fun bubbles. The size of the bubbles are dictated by how much they're
being discussed and the color is dictated by the average sentiment around that
entity. Clicking on the bubble links to the original articles. There's also a
pretty fun bar on top that you can slide and resize to adjust what timeframe
you're looking at.

*Note that [the app](http://electioninsights.mybluemix.net/) runs much better on
desktop than it does on mobile*

![app photo](/assets/images/post-images/election-insights/app.png)

This was all built on [IBM Bluemix](https://bluemix.net).

The [Election Insights](http://electioninsights.mybluemix.net/) app ([code
here](https://github.com/kauffecup/news-insights)) uses [Alchemy News
API](http://www.alchemyapi.com/products/alchemydata-news) to get all of the
data. Alchemy performs natural language processing on 75,000+ news sources as
they are published. It extracts entities and keywords, categorizes the article,
performs sentiment analyses, and a whole lot more.

Specifically, [the app](http://electioninsights.mybluemix.net/) uses Alchemy's
taxonomy breakdown to focus on all things election. Alchemy pulls out entities
from the articles and attributes how that article feels about that entity in a
sentiment analysis. The data that we get is to the effect of "that New York
Times article mentioned Donald Trump 12 times in a negative way."

At first my ambition got the better of me and I tried visualizing all incoming
news stories parsed by Alchemy. This turned out to be too variable - every
second the graph changed dramatically. Focusing on the election not only made
the data understandable and much less volatile, but allows us to interpolate it
in meaningful ways.

##the results are in

The scope of what Alchemy News parses makes the data feel truly representative
of the collective sentiment around a given entity. They parse everything from
the Wall Street Journal to Yahoo News to Reddit.

It's both international and source-agnostic.

Being able to see how the collective internet feels about an entity at a
specific time frame allows us to correlate sentiment to real time events. We can
see how a candidate's tweets transition their bubble from red to blue, or how
leaked information can shift sentiment negatively.

This provided an unintended insight; it demonstrates how one headline and
article can ripple through the news community around a common entity. We can see
posts and reposts of the same headlines rippling through the interwebs.

Some of the results were a little shocking... to me anyway. I was surprised to
see (at the time of this posting, of course) that over all the data I had
collected the net-sentiment around Trump was positive.

It would be crazy to say that data like this could predict the outcome of the
election, but hey... wanna bet?

##getting the data

The query to Alchemy looks like:

~~~bash
q.enriched.url.enrichedTitle.taxonomy.taxonomy_=|label=elections,score=>0.75|
~~~

This says to Alchemy, "return the articles that we're reasonably confident are
about elections, please." The fields we're interested in are:

~~~bash
enriched.url.title
enriched.url.url
enriched.url.entities.entity.sentiment.score
enriched.url.entities.entity.count
enriched.url.entities.entity.text
~~~

After parsing the return, Article objects look like:

~~~js
{
  _id: string,
  title: string,
  date: Date,
  url: string
}
~~~

and Entities look like:

~~~js
{
  _id: string,
  article_id: number,
  date: Date,
  text: string,
  count: number,
  sentiment: number
}
~~~

Note that each entity ties back to an article - the sentiment is how *that
article* "feels" about this entity, and the count is how many times that article
mentions this entity.

##using the data

The main technical challenge arose from parsing and retrieving the data. I
wanted the date ranges to be dynamic, and I wanted adjusting the date range to
feel instantaneous. Depending on how large the date range was, querying Alchemy
and parsing the data in Node could take between six and twelve seconds. This
meant that I couldn't use Alchemy directly for every time range adjustment, but
I had to house the data myself.

I tinkered with a few databases before I ended up using
[Mongo](https://www.mongodb.org/).

I needed fast, dynamic, map reduce on a subset of the entities in my database,
sorted by value, and limited to a certain number. Each database I looked at was
missing a step in this pipeline - the most prominent one being sorting the
result of a map reduce by value. The most common solution for this most common
problem would've been to store the result of the initial map reduce in another
collection or database, keyed and sorted by total count. Doing this would result
in unnecessary overhead - both with memory and with speed.

Mongo's Aggregation pipeline, while not full map reduce, provides exactly what I
need. Everything boils down to this awesome function:

~~~js
aggregateEntities: function (start, end, limit) {
  return new Promise(function (resolve, reject) {
    start = start || 0;
    end = end || 9999999999999;
    limit = limit || 100;
    Entity.aggregate(
      { $match: { date: { $gte: new Date(start) , $lt: new Date(end) } } },
      { $group: { _id: '$text', value: { $sum: '$count'}, sentiment: { $avg: '$sentiment'} } },
      { $sort: { value: -1} },
      { $limit: limit },
      function (err, res) {
        if (err) {
          console.error(err);
          reject(err);
        } else {
          resolve(res);
        }
      }
    );
  });
}
~~~

It matches the subset of entities by date, groups them by their text, sums the
counts, averages the sentiment, sorts them by their value descending, and limits
them to a certain amount all in one in-memory call. Doing things this way, I
only query Alchemy directly every 15m and use those results to populate my Mongo
database, and then have the application itself interact with Node which is
interacting with the database. Here's a picture:

![flow chart](/assets/images/post-images/election-insights/architecture.png)

The only services needed to deploy this in Bluemix are Alchemy and Mongo Labs.
For more info on setting this up and playing with it either locally or on
Bluemix head on over to the
[Readme](https://github.com/IBM-Bluemix/election-insights).

The other technical hurdle on my end was learning d3... but that's a story for a
different day.
