require 'uuidtools'

module Alondra
  module Connections
    extend self

    def connections
      @connections ||= {}
    end

    def [](websocket)
      connections[websocket]
    end

    def []=(websocket, connection)
      connections[websocket] = connection
    end

    def delete(websocket)
      connections.delete websocket
    end
  end

  class Connection
    attr_reader :uuid
    attr_reader :websocket
    attr_reader :session
    attr_reader :channels

    def initialize(websocket, session = {})
      @session = session.symbolize_keys
      @websocket   = websocket
      @uuid = UUIDTools::UUID.random_create

      Connections[websocket] = self
    end

    def channels
      @channels ||= []
    end

    def receive(event_or_message)
      Rails.logger.debug "sending: #{event_or_message.to_json}"
      websocket.send event_or_message.to_json
    end

    def destroy!
      channels.each { |c| c.unsubscribe self }
      Connections.delete self.websocket
    end
  end
end