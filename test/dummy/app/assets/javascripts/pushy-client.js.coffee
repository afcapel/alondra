#= require "vendor/json2"

class @PushyClient
  constructor: (channels) ->
    @socket = new WebSocket "ws://localhost:12345"

    @socket.onopen = () =>
      if channels instanceof Array
        @subscribe channel for channel in channels
      else
        @subscribe channels

    @socket.onmessage = (message) =>
      serverEvent  = JSON.parse(message.data)
      eventName    = serverEvent.event
      resourceType = serverEvent.resource_type
      resource     = serverEvent.resource

      console.log("Trigering event #{eventName} with resource #{resource}")

      # TODO: Do not use jQuery
      $(this).trigger("#{eventName}:#{resourceType}", { resource: resource})


  subscribe: (channel, credentials) ->
    console.log "subscribing to #{channel}"
    subscription =
      command: 'subscribe'
      channel: channel
      credentials: credentials

    @socket.send JSON.stringify(subscription)
