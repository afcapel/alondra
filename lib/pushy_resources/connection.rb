module PushyResources

  module Connections
    extend self

    def connections
      @connections ||= {}
    end

    def [](uid)
      connections[uid]
    end

    def []=(uid, connection)
      connections[uid] = connection
    end

    def delete(uid)
      connections.delete uid
    end
  end

  class Connection
    attr_reader :uuid
    attr_reader :websocket
    attr_reader :credentials
    attr_reader :channels

    def initialize(websocket, credentials)
      @credentials = credentials
      @uuid        = UUIDTools::UUID.random_create.to_s

      Connections[uuid] = self
    end

    def channels
      @channels ||= []
    end

    def user
      @user ||= User.where(@credentials).first
    end

    def receive(event)
      websocket.send event.to_json
    end

    def destroy
      channels.each { |c| c.unsubscribe self }
      Connections.delete uuid
    end
  end
end