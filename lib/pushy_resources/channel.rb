module PushyResources
  class Channel
    attr_reader :name
    attr_reader :em_channel
    attr_reader :connections

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
      @connections = {}
    end

    def subscribe(connection)
      sid = em_channel.subscribe do |event|
        connection.receive event
      end

      connection.channels << self
      connections[connection] = sid
    end

    def unsubscribe(connection)
      em_channel.unsubscribe connections[connection]

      connection.channels.delete self
      connections.delete connection
    end

    def receive(event)
      em_channel << event
      observers.each { |ob| ob.receive event }
    end

    def observers
      @observers ||= []
    end

    def register(observer)
      observers << observer
    end

    def unregister(observer)
      observers.delete(observer)
    end

    def users
      connections.keys.collect(&:user).compact.uniq
    end
  end
end