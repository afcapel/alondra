#= require "vendor/json2"
#= require "vendor/swfobject"
#= require "vendor/web_socket"
//= provide "../swf"

window.WEB_SOCKET_SWF_LOCATION = "/assets/WebSocketMain.swf"

class @PushyClient
  constructor: (channels, token) ->
    @socket = new WebSocket "ws://localhost:12345?token=#{token}"

    @socket.onopen = () =>
      console.log("opened connection")
      if channels instanceof Array
        @subscribe channel for channel in channels
      else
        @subscribe channels

    @socket.onclose = () =>
      console.log("connection closed")

    @socket.onmessage = (message) =>
      serverEvent  = JSON.parse(message.data)
      eventName    = serverEvent.event
      resourceType = serverEvent.resource_type
      resource     = serverEvent.resource

      console.log("Trigering event #{eventName} with resource #{resourceType} #{resource.id}")

      $(this).trigger("#{eventName}", resource)


    @socket.onerror = (error) =>
      console.log("Error #{error}")

  subscribe: (channel, credentials) ->
    console.log "subscribing to #{channel}"
    subscription =
      command: 'subscribe'
      channel: channel
      credentials: credentials

    @socket.send JSON.stringify(subscription)
