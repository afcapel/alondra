module PushyResources
  class Command
    attr_reader :name

    def initialize(connection, command_hash)
      @connection = connection

      @name         = command_hash[:command].to_sym
      @channel_name = command_hash[:channel]
    end

    def channel
      @channel ||= Channel[@channel_name]
    end

    def execute!
      case name
      when :subscribe then
        channel.subscribe @connection
      when :unsubscribe then
        channel.unsubscribe @connection
      end
    end
  end
end