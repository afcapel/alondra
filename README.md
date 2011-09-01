# Alondra

Alondra is a push server and framework that adds real time capabilities to
your rails applications.

## What can I do with Alondra?

### Subscribe clients to channels

Alondra allows browsers to subscribe to channels. Any Ruby process that loads
your Rails environment will be able to push messages to those channels.

To subscribe to a channel you can use the built in helper:

```
  <%= alondra_client @chat %>
```

Alondra uses conventions to map records and classes to channel names. The last
example will subscribe the browser to a channel named '/chats/:chat_id'. Then,
the Alondra client will render any message pushed to that channel.

If you don't want to use Alondra conventions, you can allways provide your own
channel names:

```
  <%= alondra_client ['my custom channel', 'another channel'] %>
```

### Sending push notifications

Since Alondra is all Ruby and integrates with your Rails environment, you can
use your Rails models and views to render push messages. For example, sending
a push notification from your controller action is as simple as this:

```ruby
  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.build(params[:message])

    if @message.save
      push '/messages/create', :to => @chat
    end

    respond_with @message
  end
```

This will render the '/messages/create' view and send the results to all
clients subscribed to the chat channel.

You can send push notifications from any process that loads your Rails
environment and from any class that includes the Alondra::Pushing module.
When rendering a push message the local context (that is, the instance
variables of the caller object) will be available in the view.

### Listening to events

Alondra comes bundled with an EventListener class that allows you to react to
events such as when a client subscribes to a channel.

```ruby
  # A ChatListener will by default listen to events
  # sent to any channel whose name begins with '/chat'
  class ChatListener < Alondra::EventListener

    # If you want to listen to other channels than the default ones
    # you can specify other patterns with the listen_to method, like
    #
    # listen_to  /tion$/
    #
    # That would make your listener receive events from any channel whose
    # name ends in 'ion'


    # This will be fired any time a client subscribes to
    # any of the observed channels
    on :subscribed, :to => :member do

      # If you use Cookie Based Session Store,
      # you can access the Rails session from the listener
      @user = User.find(session[:user_id])

      # Push notifications from listener
      push '/users/user', :to => channel_name
    end
  end
```

You can also listen to :unsubscribe, :created, :updated, :destoyed or any
custom event in the observed channels.

### Push record changes to the client

Sometimes you are just interested in pushing record updates to subscribed
clients. You can do that annotating your model:

```ruby
  class Presence < ActiveRecord::Base
    belongs_to :user
    belongs_to :chat

    push :changes, :to => :chat

  end
```

This will push an event (:created, :upated or :destroyed)  to the chat channel
each time a Message instance changes.

In the client you can listen to these events using the JavaScript API:

```javascript

  var alondraClient = new AlondraClient('localhost', 12345, ['/chat_rooms/1']);

  // render user name when presence is created

  $(alondraClient).bind("created.Presence", function(event, resource){
    if( $('#user_'+resource.user_id).length == 0 ){
      $('#users').append("<li id='user_" + resource.user_id + "'>" + resource.username + "</li>");
    }
  });

  // remove user name when presence is destroyed

  $(alondraClient).bind("destroyed.Presence", function(event, resource){
    $('#user_'+resource.user_id).remove();
  });

```

This technique is especially useful if you use something like Backbone.js
to render your app frontend.


## Example application

You can check the [example application](http://github.com/afcapel/alondra-example)
to see how some of the features are used.

## Installation

Currently Alondra depends on Rails 3.1 and Ruby 1.9. It also uses ZeroMQ for
interprocess communication, so you you need to install the library first. If
you are using Homebrew on Mac OS X, just type

<pre>
  brew install zeromq
</pre>

When ZeroMQ is installed, add the Alondra gem to your Gemfile.

<pre>
  gem "alondra"
</pre>

You also will need to install the server initialization script into your app.
In the shell execute the generator.

<pre>
  $ rails g alondra install
</pre>

To run the Alondra server, just call the generated script

<pre>
  $ script/alondra start
</pre>

In development mode you can also run the Alondra server in its own thread.
See the [initializer in the example application](https://github.com/afcapel/alondra-example/blob/master/config/initializers/alondra_server.rb)
for how to do it.
