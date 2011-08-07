module PushyResources
  class Command
    attr_reader :name
    attr_reader :channel_name

    def initialize(connection, command_hash)
      @connection = connection

      @name         = command_hash[:command].to_sym
      @channel_name = command_hash[:channel]
    end

    def channel
      @channel ||= Channel[channel_name]
    end

    def execute!
      case name
      when :subscribe then
        puts "SUBSCRIBED"
        channel.subscribe @connection
        fire_event :subscribed
      when :unsubscribe then
        channel.unsubscribe @connection
        fire_event :unsubscribed
      end
    end

    def fire_event(event_type)
      event = Event.new :event    => event_type,
                        :resource => @connection.user || @connection.credentials,
                        :channel  => @channel_name

      event.fire!
    end
  end
end