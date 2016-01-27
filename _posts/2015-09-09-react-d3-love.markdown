---
layout: post
title:  "React + D3 = <3"
date:   2015-09-09 15:22:08 -0500
categories: react d3
---

TL;DR - Using D3 with React is awesome. I put an animated bubble chart React+D3
component on npm. You can find that
[here](https://www.npmjs.com/package/react-bubble-chart). The code for it is
[here](https://github.com/kauffecup/react-bubble-chart). The initial code was
developed for the "Election Insights" app that I built (blog post on that
[here](www.jkaufman.io/election-insights/), the app itself
[here](electioninsights.mybluemix.net)). If you want to read more about how it
was done, keep scrollin'.

![gif](http://i.imgur.com/OQEdgOW.gif)

...who doesn't love bubbles?

## let's get down to business

When Connecting React+D3 I followed the three guidelines [presented
here](http://nicolashery.com/integrating-d3js-visualizations-in-a-react-app/).
In case you don't want to read that, they are:

  1. **One Source Of Truth**: The D3 visualization should get all of the data it
  needs to render passed down to it. 1. **Stateless All The Things**: This is
  related to (1). D3 and React components alike should be as stateless as
  possible, i.e. they shouldn't hide/encapsulate something that makes them
  render differently given the same "input". 1. **Don't Make Too Many
  Assumptions**: This is related to (1) and (2). Components shouldn't make too
  many assumptions about how they will be used.

The goal is to keep our D3 component in the same lifecycle as our React
component. This is surprisingly easy as both libraries follow similar
mentalities - there's some kind of initial set up, and as your data changes the
updates are described declaratively.

This means the structure of the React component itself needs to look like:

{% highlight js %}
import ReactBubbleChartD3 from './ReactBubbleChartD3';
import React              from 'react';

class ReactBubbleChart extends React.Component {
  render () {
    return <div className="bubble-chart-container"></div>;
  }

  componentDidMount () {
    ReactBubbleChartD3.create(this.getDOMNode(), this.getChartState());
  }

  componentDidUpdate () {
    ReactBubbleChartD3.update(this.getDOMNode(), this.getChartState());
  }

  getChartState () {
    return {
      data: this.props.data,
      colorLegend: this.props.colorLegend,
      fixedDomain: this.props.fixedDomain,
      selectedColor: this.props.selectedColor,
      selectedTextColor: this.props.selectedTextColor,
      onClick: this.props.onClick || () => {}
    }
  }

  componentWillUnmount () {
    ReactBubbleChartD3.destroy(this.getDOMNode());
  }

  getDOMNode () {
    return React.findDOMNode(this);
  }
}

export default ReactBubbleChart;
{% endhighlight %}

 Pretty simple so far - when our React component is mounted we create our D3
component, when our React component updates we update our D3 component, when
our React component is removed we destroy our D3 component. We also give our D3
component access to all of the props in our React component. This keeps them
both stateless with access to one "universal truth."

The skeleton of our D3 component looks like:

{% highlight js %}
import d3 from 'd3';
var ReactBubbleChartD3 = {};
var svg, html, bubble;

/* Initialization */
ReactBubbleChartD3.create = function (el, props) {
  props = props || {};
  // reference to svg element containing circles
  svg = d3.select(el).append('svg')
    .attr('class', 'bubble-chart-d3');
  // reference to html element containing text
  html = d3.select(el).append('div')
    .attr('class', 'bubble-chart-text');
  // create the bubble layout that we will use to position our bubbles
  bubble = d3.layout.pack()
    .sort(null)
    .size([diameter, diameter])
    .padding(3);
  this.update(el, props);
}

/* Update */
ReactBubbleChartD3.update = function (el, props) {
  var data = props.data;
  if (!data) return;

  // generate data with calculated layout values
  var nodes = bubble.nodes({children: data})
    .filter((d) => !d.children); // filter out the outer bubble

  // assign new data to existing DOM for circles and labels
  var circles = svg.selectAll('circle')
    .data(nodes, (d) => 'g' + (d.displayText || d._id));
  var labels = html.selectAll('.bubble-label')
    .data(nodes, (d) => 'g' + (d.displayText || d._id));

  // code to handle update
  // code code code code code

  // code to handle initial render
  // code code code code code

  // code to handle exit
  // code code code code code
}

/** Any necessary cleanup */
ReactBubbleChartD3.destroy = function (el) {}

export default ReactBubbleChartD3;
{% endhighlight %}

 Again, the full code can be found
[here](https://github.com/kauffecup/react-bubble-chart).

## the magical update method

We'll dive in to the omitted sections in a bit... but the `update` method is
really where the magic happens. It's broken in to 3 (well... 4) sections:

  - **0. Initialization** - build an array of "data nodes" using our bubble
  layout. This uses D3 magic that figures out the size and position of the
  bubbles based on our data array. We also grab a reference to all of our
  existing circles and labels.
  - **1. Set up our transitions** - the transition
  is only applied to updating nodes. We create the transition on the updating
  elements before the entering elements because enter.append merges entering
  elements into the update selection.
  - **2. Handle incoming nodes** - we
  `enter` our circles and labels references and append either a circle or div
  in the correct place.
  - **3. Handle exiting nodes** - we `exit` our circles
  and labels references, animate them out, and then remove them from the DOM.

Before our dive in to some more codes - let's answer a question:

> Why do you have a `<svg>` block containing only `<circle>` elements, and a
sibling `<html>` block containing `<div>`s with all of the text?

Short answer: easier for text wrapping and animation.

Long answer: read [this
article](http://vallandingham.me/building_a_bubble_cloud.html). It's tricky to
get text to wrap with svgs (you have to do it manually by measuring how long the
text is going to be and break it up yourself), but with html... you can do the
same thing with some simple CSS.

## ok, back to some more code

Some of the animation math was inspired from the animated bubble chart in [this
article](http://www.pubnub.com/blog/fun-with-d3js-data-visualization-eye-candy-with-streaming-json/).
Definitely give it a read... it's quite easy to parse even if you've never done
any D3 before.

### Initialization

This is arguably the trickiest part to get "right." I had a few frustrating
hours of referencing incorrect elements... or my scope being wrong...

We want our transition code to affect nodes changing positions, our entry code
to only affect new nodes, and our exit code to only affect leaving nodes. I was
primarily seeing new bubbles created and never moved - only my entry code was
being hit, not my transition or exit code.

The key for me was to make sure that my reference to the `svg` node and `html`
node were the same ones initialized in the `create()` method. Once these were
the same doing `svg.selectAll('circle')...` worked as expected.  In context:

{% highlight js %}
  // define a color scale for our bubble chart
  var color = d3.scale.quantize()
    .domain([
      props.fixedDomain ? props.fixedDomain.min : d3.min(data, d => d.colorValue),
      props.fixedDomain ? props.fixedDomain.max : d3.max(data, d => d.colorValue)
    ])
    .range(colorRange);

  // generate data with calculated layout values
  var nodes = bubble.nodes({children: data})
    .filter((d) => !d.children); // filter out the outer bubble

  // assign new data to existing DOM for circles and labels
  var circles = svg.selectAll('circle')
    .data(nodes, (d) => 'g' + d._id);
  var labels = html.selectAll('.bubble-label')
    .data(nodes, (d) => 'g' + d._id);
{% endhighlight %}

 So there's a few things going on here. We initialize our color scale
(`colorRange` is passed in) and allow it to be a fixedDomain or determined by
the min and max values in our data array.

We then build our layout (using the earlier discussed D3 magic).

Now that we have our nodes, we pass them in as data to both the circles and
labels. D3 uses the `_id` property to determine which bubbles will be changing
places, which ones are entering, and which ones are leaving.

### Set up transitions

Once we have the correct references to the correct nodes with the correct `_id` values, the rest is a piece of cake... ish.

{% highlight js %}
  // for circles we transition their transform, r, and fill
  circles.transition()
    .duration(duration)
    .delay((d, i) => {delay = i * 7; return delay;})
    .attr('transform', (d) => 'translate(' + d.x + ',' + d.y + ')')
    .attr('r', (d) => d.r)
    .style('opacity', 1)
    .style('fill', d => d.selected ? selectedColor : color(d.colorValue));
  // for the labels we transition their height, width, left, top, and color
  labels.transition()
    .duration(duration)
    .delay((d, i) => {delay = i * 7; return delay;})
    .style('height', d => 2 * d.r + 'px')
    .style('width', d => 2 * d.r + 'px')
    .style('left', d =>  d.x - d.r + 'px')
    .style('top', d =>  d.y - d.r + 'px')
    .style('opacity', 1)
    .style('color', d => d.selected ? selectedTextColor : '');
{% endhighlight %}

This code reads pretty much 1:1 with what's actually going on. The bubble layout
method appends an `x`, `y`, and `r` property on to our data set, allowing us to
know where they should go and how big they should be. Each D3 chained method is
applied to each node in our dataset. This transitions the existing nodes from
their current location to their new location. It is only applied to nodes whose
`_id` is both in the current set, and the new set.

### Handle incoming nodes

Apart from `.enter().append(...)`, this section is very similar to the previous
section. For each node we append both a `<circle>` under the `<svg>` block and a
`<div>` under the `<html>` block. We use attributes to position the circles in
the correct spot and styles to position the divs in the correct spot. There's
also some fancy transition stuff going on here... just to make it look cooler.

{% highlight js %}
  // enter - only applies to incoming elements (once emptying data)
  if (data.length) {
    // initialize new circles
    circles.enter().append('circle')
      .attr('transform', (d) => 'translate(' + d.x + ',' + d.y + ')')
      .attr('r', (d) => 0)
      .attr('class', 'bubble')
      .style('fill', d => d.selected ? selectedColor : color(d.colorValue))
      .transition()
      .duration(duration * 1.2)
      .attr('transform', (d) => 'translate(' + d.x + ',' + d.y + ')')
      .attr('r', (d) => d.r)
      .style('opacity', 1);
    // intialize new labels
    labels.enter().append('div')
      .attr('class', 'bubble-label')
      .text(d => d.displayText || d._id)
      .on('click', (d,i) => {d3.event.stopPropagation(); props.onClick(d)})
      .style('position', 'absolute')
      .style('height', d => 2 * d.r + 'px')
      .style('width', d => 2 * d.r + 'px')
      .style('left', d =>  d.x - d.r + 'px')
      .style('top', d =>  d.y - d.r + 'px')
      .style('opacity', 0)
      .transition()
      .duration(duration * 1.2)
      .style('opacity', 1);
  }
{% endhighlight %}

### Handle exiting nodes

This could be as simple as just calling `.remove()` but we're too fancy for
that, aren't we? Let's animate them going out so that our circles don't just
disappear:

{% highlight js %}
  // exit - only applies to... exiting elements
  // for circles have them shrink to 0 as they're flying all over
  circles.exit()
    .transition()
    .duration(duration)
    .attr('transform', (d) => {
      var dy = d.y - diameter/2;
      var dx = d.x - diameter/2;
      var theta = Math.atan2(dy,dx);
      var destX = diameter * (1 + Math.cos(theta) )/ 2;
      var destY = diameter * (1 + Math.sin(theta) )/ 2;
      return 'translate(' + destX + ',' + destY + ')'; })
    .attr('r', 0)
    .remove();
  // for text have them fade out as they're flying all over
  labels.exit()
    .transition()
    .duration(duration)
    .style('top', (d) => {
      var dy = d.y - diameter/2;
      var dx = d.x - diameter/2;
      var theta = Math.atan2(dy,dx);
      var destY = diameter * (1 + Math.sin(theta) )/ 2;
      return destY + 'px'; })
    .style('left', (d) => {
      var dy = d.y - diameter/2;
      var dx = d.x - diameter/2;
      var theta = Math.atan2(dy,dx);
      var destX = diameter * (1 + Math.cos(theta) )/ 2;
      return destX + 'px'; })
    .style('opacity', 0)
    .style('width', 0)
    .style('height', 0)
    .remove();
{% endhighlight %}

## and in the end...

...the D3 you take, is equal to the D3 you make.

In case you didn't catch the three articles I used to learn how to build this,
I'll paste 'em right here:

  - [Integrating D3 Visualizations in a React
  App](http://nicolashery.com/integrating-d3js-visualizations-in-a-react-app/)
  - [Building a Bubble
  Cloud](http://vallandingham.me/building_a_bubble_cloud.html) [Fun with D3
  - Data
  Visualization](http://www.pubnub.com/blog/fun-with-d3js-data-visualization-eye-candy-with-streaming-json/)

And in case you missed these other fun links, here they are:

  - [Live demo of ReactBubbleChart](http://electioninsights.mybluemix.net/)
  - [The code for that demo](https://github.com/IBM-Bluemix/election-insights)
  - [My blog post about that demo](http://www.jkaufman.io/election-insights/).

This was my first experience ever using D3... and jumping in with React made for
quite the learning curve. Let me know if you want any clarification on any part
of the code, or if something in this post wasn't quite clear.

React + D3 = <3
