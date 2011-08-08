module PushyResources

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
    attr_reader :credentials
    attr_reader :channels

    def initialize(websocket, credentials)
      credentials ||= {}
      @credentials = credentials.stringify_keys
      @websocket   = websocket
      @uuid = UUIDTools::UUID.random_create

      Connections[websocket] = self
    end

    def channels
      @channels ||= []
    end

    def user
      User.where(credentials_to_param).first if credentials_to_param
    end

    def receive(event)
      websocket.send event.to_json
    end

    def destroy!
      channels.each { |c| c.unsubscribe self }
      Connections.delete self.websocket
    end

    private

    def credentials_to_param
      return {:id => warden_user_id }        if warden_user_id
      return {:id => credentials['user_id']} if credentials['user_id']
      return {:id => credentials['id']}      if credentials['id']

      nil
    end

    def warden_user_id
      credentials['warden.user.user.key'] && credentials['warden.user.user.key'][1].first
    end

  end
end