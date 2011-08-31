# Alondra

Alondra is a push server and framework that adds real time capabilities to your rails applications.

## What can I do with Alondra?

These are some things you can do with Alondra.

### Subscribe clients to channels

Alondra allow browsers to subscribe to channels. Any Ruby proccess that load your rails environment can
then push messages to those channels. To subscribe to a channel you can use the built in helper:

<pre>
  <%= alondra_client @chat %>
</pre>

This will subscribe the browser to a channel named '/chats/:chat_id'. The alondra client will render any
message pushed to that channel.

### Sending push notifications

Since Alondra is all Ruby and integrates with your Rails environment, you can your rails models and views.
For example, sending a push notifications from your controller action is as simple as this:

```ruby
  push '/messages/create', :to => @chat
```

You can also listen to :unsubscribe, :created, :updated, :destoyed or any
custom event in the observed channels.

### Listening to events

Alondra come bundled with an EventListener class that allows you to react to events, such as when a client
subscribe to a channel.

```ruby
  # A chat listener will by default listen to events
  # sent to channel whose name begins with '/chat'
  class ChatListener < Alondra::EventListener

    # If you want to listen to other channels than the default ones
    # you can specify another patterns with the listen_to method, like
    #
    # listen_to  /tion$/
    #
    # That would make your listener to receive event to any channel whose
    # name ends in 'ion'


    # This will be fire any time a client subscribe to
    # any of the observed channels
    on :subscribed, :to => :member do
      @user = user
      push '/users/user', :to => channel_name
    end
  end
```

### Push record changes to the client

Some times you are just interested in pushing record updates to subscribed clients.
This is as annotating your model:

```ruby
  class Presence < ActiveRecord::Base
    belongs_to :user
    belongs_to :chat

    push :changes, :to => :chat

  end
```

This will push an event (:created, :upated or :destroyed)  to the chat channel
each time a Message instance changes.

## Example application

You can check the [example application](http://github.com/afcapel/alondra-example) to see how some of the features are used.

## Installation

Currently Alondra depends on Rails 3.1 and Ruby 1.9. It also uses ZeroMQ for
interprocess communication, so you you need to install the library first. If
you are using Homebrew, just type

<pre>
  brew install zeromq
</pre>

When ZeroMQ is installed, just add the alondra gem to your Gemfile.

<pre>
  gem "alondra"
</pre>

You also will need to install the server initialization script into your app.
In the shell execute the generator.

<pre>
  $ rails g alondra install
</pre>

To run the alondra server, just call the generated script

<pre>
  $ script/alondra start
</pre>

In development mode you can also run the alondra server in its own thread.
See the [initializer in the example application](https://github.com/afcapel/alondra-example/blob/master/config/initializers/alondra_server.rb)
for how to do it.


