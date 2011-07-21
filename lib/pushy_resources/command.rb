module PushyResources
  class Command
    attr_reader :name

    def initialize(websocket, command_hash)
      @websocket = websocket

      @name         = command_hash[:command].to_sym
      @channel_name = command_hash[:channel]
      @credentials  = command_hash[:credentials]
    end

    def channel
      @channel ||= Channel[@channel_name]
    end

    def execute!
      case name
      when :subscribe then
        channel.subscribe @websocket, @credentials
      when :unsubscribe then
        subscriptions = Subscription.subscriptions_for(@websocket)
        subscriptions = subscriptions.select { |s| s.channel == @channel } if @channel

        subscriptions.each(&:destroy!)
      end
    end
  end
end