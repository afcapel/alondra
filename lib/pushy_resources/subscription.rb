module PushyResources
  class Subscription
    attr_reader :uid
    attr_reader :channel
    attr_reader :websocket
    attr_reader :credentials

    class << self
      def websockets
        @websocket_list ||= {}
      end

      def subscriptions_for(websocket)
        websockets[websocket] ||= []
      end
    end

    def initialize(channel, ws, credentials = nil)
      @websocket = ws
      @channel = channel
      @credentials = credentials

      @user_id = credentials[:user_id] if credentials

      @uid = @channel.em_channel.subscribe do |event|
        self.receive(event)
      end

      Subscription.subscriptions_for(ws) << self
    end

    def user
      User.find(@user_id) if @user_id
    end

    def receive(event)
      websocket.send event.to_json
    end

    def destroy!
      subscriptions_for(websocket).delete(self)
      channel.unsubscribe(self)
    end
  end
end