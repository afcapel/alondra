#= require "vendor/json2"
#= require "vendor/swfobject"
#= require "vendor/web_socket"
//= provide "../swf"

window.WEB_SOCKET_SWF_LOCATION = "/assets/WebSocketMain.swf"

class @AlondraClient
  constructor: (host, port, channels, token = null, retry = 5000) ->
    @channels = channels
    @token    = token
    @retry    = retry
    @url = "ws://#{host}:#{port}"

    @url += "?token=#{@token}" if @token

    this.connect()

  subscribe: (channel) ->
    subscription =
      command: 'subscribe'
      channel: channel

    @socket.send JSON.stringify(subscription)

  connect: ->
    @socket   = new WebSocket(@url)

    @socket.onopen = () =>
      if @reconnectInterval
        clearInterval(@reconnectInterval)
        @reconnectInterval = null

      if @channels instanceof Array
        this.subscribe(channel) for channel in @channels
      else
        this.subscribe(@channels)

    @socket.onclose = () =>
      this.reconnect()


    @socket.onmessage = (message) =>
      msg = JSON.parse(message.data)
      if msg.event
        this.process(msg)
      else
        this.execute(msg)


    @socket.onerror = (error) =>
      this.reconnect()

  process: (serverEvent) ->
    eventName    = serverEvent.event
    resourceType = serverEvent.resource_type
    resource     = serverEvent.resource

    $(this).trigger("#{eventName}.#{resourceType}", resource)

  execute: (message) ->
    eval(message.message)

  reconnect: ->
    return if !@retry || @reconnectInterval

    @reconnectInterval = setInterval =>
      this.connect()
    ,@retry

