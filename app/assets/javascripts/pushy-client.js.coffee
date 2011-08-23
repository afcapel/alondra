#= require "vendor/json2"
#= require "vendor/swfobject"
#= require "vendor/web_socket"
//= provide "../swf"

window.WEB_SOCKET_SWF_LOCATION = "/assets/WebSocketMain.swf"

class @PushyClient
  constructor: (channels, token, retry = 5000) ->
    @channels = channels
    @token    = token
    @retry    = retry

    this.connect()

  subscribe: (channel) ->
    console.log "subscribing to #{channel}"
    subscription =
      command: 'subscribe'
      channel: channel

    @socket.send JSON.stringify(subscription)

  connect: ->
    console.log("connecting...")
    @socket   = new WebSocket "ws://localhost:12345?token=#{@token}"

    @socket.onopen = () =>
      console.log("opened connection")
      if @reconnectInterval
        console.log("reconected!")
        clearInterval(@reconnectInterval)
        @reconnectInterval = null

      if @channels instanceof Array
        this.subscribe(channel) for channel in @channels
      else
        this.subscribe(@channels)

    @socket.onclose = () =>
      console.log("connection closed")
      this.reconnect()


    @socket.onmessage = (message) =>
      serverEvent  = JSON.parse(message.data)
      eventName    = serverEvent.event
      resourceType = serverEvent.resource_type
      resource     = serverEvent.resource

      console.log("Trigering event #{eventName} with resource #{resourceType} #{resource.id}")

      $(this).trigger("#{eventName}.#{resourceType}", resource)


    @socket.onerror = (error) =>
      console.log("Error #{error}")
      this.reconnect()

  reconnect: ->
    return if !@retry || @reconnectInterval

    console.log("trying to reconnect")

    @reconnectInterval = setInterval =>
      this.connect()
    ,@retry

