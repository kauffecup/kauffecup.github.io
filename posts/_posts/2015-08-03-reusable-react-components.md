---
layout: post
title: "Creating Reusable React Components"
tags: react
description: >
  How to manage state in your React application to promote reusable and more
  awesome components.
---

Hold on to your hats, kids, this one's got a lot of code.

React is more powerful the tinier each component is - it makes the overall
application easier to navigate and encourages as many components as possible to
be stateless. Breaking down common design elements (buttons, form fields, layout
components) into reusable components with well-defined interfaces will increase
consistency across your application's look and feel, and minimize effort when
building future UI. This allows for cross team collaboration, increases
maintainability, speeds up development time, eliminates bugs, and reduces the
file-size of your application.

##Top-Level Functional Area Components

Only **top-level functional area components** should hold state.

###What does this mean?

Let's say, for example, you were building an email application. This app has a
message list, a message read area, and a calendar area. The message list
contains rows of messages, the message read area contains an open message with a
bunch of associated actions and content, and the calendar is full of entries.
This application will contain three top-level functional area components.

In very large applications it's best to have each area manage its own state,
meaning that all three of the functional area components will hold state. In
smaller applications, it's best to have the main top level component manage all
of the state, meaning that only one component will hold state.

###What do you mean by application state?

In this example, the application state would be the messages, the message
content (the selected message), and the calendar entries. In addition to
application state, you can have UI-level state such as whether a menu is open or
closed.

###How would we re-use the MessageList in different applications with different sources?

I'm glad you asked.

If the `MessageList` was defined as such:

~~~js
import React        from 'react';
import MessageRow   from './MessageRow';
import messageStore from '../store/messageStore';

export class MessageList extends React.Component {
  constructor (props) {
    super(props);
    this.state = {messages: []};
  }

  componentDidMount () {
    messageStore.onUpdate(ms => { this.setState({messages: ms}); });
  }

  render () {
    var messages = this.state.messages.map(message =>
      <MessageRow message={message} key={message.id} />;
    );
    return <ul className='messageList'>{messages}</ul>;
  }
};
~~~

Then we wouldn't be able to just drop it in another application (unless that
application had a file called `messageStore` that was a sibling of this file,
with an `onUpdate` method - all of which would insane requirements to have).

 Instead, we should define messages only as a `prop`, and write our
`MessageList` as this:

~~~js
import React       from 'react';
import MessageRow  from './MessageRow';

export class MessageList extends React.Component {
  render () {
    var messages = this.props.messages.map(message => {
      return <MessageRow message={message} key={message.id} />;
    });
    return <ul className='messageList'>{messages}</ul>;
  }
};
~~~

In a small application, we can now plop this in to our main component:

~~~js
import React         from 'react';
import Actions       from './Actions';
// stores
import MessageStore  from './stores/PageStore';
import CalendarStore from './stores/CommentStore';
import PreviewStore  from './stores/BotStore';
// components
import MessageList   from './components/MessageList';
import Calendar      from './components/Calendar';
import MessageRead   from './components/MessageRead';

class MyApp extends React.Component {
  constructor (props) {
    super(props);
    this.state = this._getStateObj();
  }

  render () {
    return (
      <div className='my-really-cool-app'>
        <h1 className='my-really-cool-title'>This is a title!</h1>
        <MessageList messages={this.state.messages} />
        <Calendar calendarEntries={this.state.calendarEntries} />
        <MessageRead openMessage={this.state.openMessage} />
      </div>
    );
  }

  /** When first in the page, set up change handlers,
    * and kick off initial requests */
  componentDidMount () {
    // add change listeners for stores
    MessageStore.addChangeListener(this._onChange);
    CalendarStore.addChangeListener(this._onChange);
    PreviewStore.addChangeListener(this._onChange);
    // load initial batch of messages
    Actions.loadMessages();
  }

  /** When the stores update, re-set our state to trigger a render */
  _onChange () {
    this.setState(this._getStateObj());
  }

  /** The state for the app */
  _getStateObj () {
    return {
      messages: MessageStore.getMessages(),
      calendarEntries: CalendarStore.getCalendarEntries(),
      openMessage: PreviewStore.getPreview()
    }
  }
};

React.render(<MyApp />, document.body);
~~~

 In a large application, we should define a wrapper top-level functional area
component that would look like:

~~~js
import React        from 'react';
import MessageRow   from './MessageRow';
import messageStore from '../store/messageStore';

export class MessagesView extends React.Component {
  constructor (props) {
    super(props);
    this.state = {messages: []};
  }

  componentDidMount () {
    messageStore.onUpdate(ms => { this.setState({messages: ms}); });
  }

  render () {
    return <MessageList messages={this.state.messages} />;
  }
};
~~~

 While this might seem like a piece of extraneous work, it splits up the state
management from the rendering, allowing us to re-use this `MessageList` in any
context that might get its `messages` from another store or from another
application entirely.

...and that's the dream.
