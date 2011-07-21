module PushyResources
  class Channel
    attr_reader :name
    attr_reader :em_channel
    attr_reader :subscribers

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
      @subscribers = []
    end

    def subscribe(websocket, credentials = nil)
      subscriber = Subscriber.new(self, websocket, credentials)

      @subscribers << subscriber
      subscriber
    end

    def unsubscribe(subscriber)
      @subscribers.delete(subscriber)
    end

    def receive(event)
      @em_channel << event
    end

    def users
      @subscribers.collect(&:user).compact.uniq
    end
  end
end