module Alondra
  class ListenerCallback
    attr_reader :event_type
    attr_reader :options
    attr_reader :proc

    CHANNEL_NAME_PATTERN = %r{\d+$}

    def initialize(event_type, options = {}, proc)
      @event_type = event_type
      @options    = options
      @proc       = proc
    end

    def matches?(event)
      return false unless event.type == event_type

      case options[:to]
      when nil then true
      when :member then
        member_channel? event.channel_name
      when :collection then
        !member_channel?(event.channel_name)
      end
    end

    private

    def member_channel?(channel_name)
      channel_name =~ CHANNEL_NAME_PATTERN
    end
  end
end