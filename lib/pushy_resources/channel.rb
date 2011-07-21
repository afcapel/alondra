module PushyResources
  class Channel
    attr_reader :name
    attr_reader :em_channel
    attr_reader :subscriptions

    class << self
      def list
        @channel_list ||= {}
      end

      def [](name)
        list[name] ||= Channel.new(name)
      end
    end

    def initialize(name)
      @name = name
      @em_channel = EM::Channel.new
      @subscriptions = []
    end

    def subscribe(websocket, credentials = nil)
      subscription = Subscription.new(self, websocket, credentials)

      @subscriptions << subscription
      subscription
    end

    def unsubscribe(subscription)
      @subscriptions.delete(subscription)
    end

    def receive(event)
      @em_channel << event
    end

    def users
      @subscriptions.collect(&:user).compact.uniq
    end
  end
end