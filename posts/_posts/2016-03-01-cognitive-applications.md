---
layout: post
title: "...Cognitive Apps?"
tags: [cognitive, discussion]
image: assets/images/post-images/cognitive-apps/header.jpg
description: >
  Cognitive systems are probabilistic. They generate not just answers to
  numerical problems, but hypotheses, about more complex bodies of data.
---

The more I interact with "smart apps" (and people talking about their own
"smart apps") that are "based on machine learning," the more I hear the word
"cognitive" being thrown around. But what actually does this imply? What is a
cognitive application? Can I make my app smarter? Can I make my app *cognitive*?

There's really no better starting point than this blunt quote from
[Wikipedia][wkp]:

>Cognitive computing, a buzzword and computing concept by *IBM*,
aims at making human kinds of problems computable.

...and I suppose we might as well also look at this quote from [IBM][ibm]:

>Cognitive systems are probabilistic. They generate not just answers to
numerical problems, but *hypotheses*, reasoned arguments and recommendations
about more complex — and meaningful — bodies of data.

{% include ad-blog.html %}

### but what does any of this actually mean?

When dealing with buzzwords, it's important to filter out the bullsh*t from the
content.

An app is truly "cognitive" when it learns and reasons from and with the user,
and doesn't need each possible path programmed. If an app only functions for its
designed purpose, even if that purpose uses some fancy-awesome-out-of-this-world
algorithm, it isn't considered "cognitive."

### ok, I'm still confused by all of the buzzwords being thrown around.

I've always found it best to walk through an example, no matter how hypothetical
it may be. The quintessential cognitive example is some kind of personal
assistant, but that's boring so let's pick something else.

Let's pick something crazy exciting... like shopping? But seriously, *shopping*.
The *most* exciting.

_(really I'm just picking it because all of you buy things on the internet so
it'll make for an easy example)_

![non cognitive shopping](/assets/images/post-images/cognitive-apps/shopping.png)

We're all familiar with a shopping-web-app of this design. You've got your
search bar for... searching, some kind of faceted search results or other kind
of list on the left, some kind of list of items in the center, some links to
your cart and account, and maybe a right panel for doing something.

An application of this sort can be broken down to a series of state machines:

![non cognitive flow](/assets/images/post-images/cognitive-apps/flow1.png)

Let's assume for a second that this is both correct and complete.

When an application's behavior can be this well defined, the user needs to learn
how to use the system to be productive. If this shopping app were instead
"cognitive" it would adapt to the user's current needs making it both
interactive and contextual.

### alright, so let's make it cognitive.

Well... I just lied. The first thing we're going to do is throw some machine
learning into the mix and show why that in-and-of-itself *won't* make this a
"cognitive shopping app."

This machine learning we're gonna add is a state-of-the-art search engine that
learns from both the current user and the community to suggest the most relevant
items. It's also going to have crazy good autocomplete, because why not?

So to recap:

![search enhancements](/assets/images/post-images/cognitive-apps/crazygoodsearch.png)

If this uses natural language processing, *and* machine learning, *and* enhances
our user experience, why is this application not yet *cognitive*?

Quite simply, all we've done is replace one block in our state machine. While,
yes, the new block is "smart" and does "learn," we haven't yet updated our
system as a whole. We've introduced some cognition, but have not yet arrived
at a "cognitive application."

### forrealz now, let's make it cognitive.

Let's start with an updated flow chart for using our fresh and new cognitive
shopping app:

![cognitive flow](/assets/images/post-images/cognitive-apps/flow2.png)

This may seem crazy, but if we can pull this off, we can call this application
truly cognitive. In this system, we teach our app all possible actions it can
take (search, browse, etc.), and then rely on the "brain" to do the right
thing when presented with the right interaction.

With this flow chart, we no longer need to have a separate part of our UI for
each possible action. We won't need the search bar to be separate from an item
list, etc, all we'll need is a way for our user to interact with the system.

And what better way to interact with a cognitive system, than with voice or
text?

![conversation](/assets/images/post-images/cognitive-apps/conversation.png)

Well, ok, maybe there are better ways to interact with a cognitive system
other than voice or text, but I'll be the first one to admit I'm not the best
at designing UIs - especially crazy-awesome cognitive ones.

But we can collectively imagine a UI that updates and adapts as the "brain"
interprets the user input. And isn't that cool?

{% include ad-blog.html %}

### one last thing

You may have noticed I didn't go into any "hows" in this post. That's because,
well, this post was meant to be a higher level discussion, and quite frankly
I don't know exactly how I would approach this kind of problem. I'm also not
aware of an application that is 100% cognitive by my very strict definition.

Perhaps one day I'll figure out the "how" and link back to this post. That'll
be a good day. A good day, indeed.

[wkp]: https://en.wikipedia.org/wiki/Cognitive_computing
[ibm]: http://www.research.ibm.com/software/IBMResearch/multimedia/Computing_Cognition_WhitePaper.pdf
