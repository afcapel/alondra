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

      def for(records)
        case records
        when String
          [Channel[records]]
        when Enumerable then
          records.collect { |r| Channel.default_name_for(r) }
        else
          [Channel.default_name_for(records)]
        end
      end

      def default_name_for(resource_or_class, type = :member)

        if resource_or_class.kind_of?(Class)
          resource_name = resource_or_class.name.pluralize.underscore
        else
          resource      = resource_or_class
          resource_name = resource.class.name.pluralize.underscore
        end

        case type
        when :member then
          "/#{resource_name}/#{resource.id}"
        when :collection then
          "/#{resource_name}/"
        end
      end
    end

    def initialize(name)
      @name = name
      @em_channel = EM::Channel.new
      @connections = {}
    end

    def subscribe(connection)
      sid = em_channel.subscribe do |event_or_message|
        connection.receive event_or_message
      end

      connection.channels << self
      connections[connection] = sid
    end

    def unsubscribe(connection)
      em_channel.unsubscribe connections[connection]

      connection.channels.delete self
      connections.delete connection

      event = Event.new :event    => :unsubscribed,
                        :resource => connection.user || connection.credentials,
                        :channel  => name

      event.fire!
    end

    def receive(event_or_message)
      em_channel << event_or_message
    end

    def users
      connections.keys.collect(&:user).compact.uniq
    end
  end
end