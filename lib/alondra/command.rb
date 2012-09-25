module Alondra
  class Command
    attr_reader :name
    attr_reader :connection
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
        channel.subscribe @connection
        fire_event :subscribed
      when :unsubscribe then
        # :unsubscribed event will be fired in Channel#unsubscribe
        channel.unsubscribe @connection
      end
    end

    def fire_event(event_type)
      event_hash = {
        :event         => event_type,
        :resource      => @connection.session,
        :resource_type => @connection.session.class.name,
        :channel       => @channel_name
      }

      Event.new(event_hash, nil, connection).fire!
    end
  end
end