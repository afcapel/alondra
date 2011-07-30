require 'singleton'

module PushyResources
  class EventObserver
    include Singleton

    def channels
      @channels ||= []
    end

    def self.observe(channel_name)
      observer = self.instance
      channel = Channel[channel_name]

      observer.channels << channel
      channel.observers << observer
    end

    def self.on(event_type, &block)
      instance.callbacks_for(event_type) << block
    end

    def callbacks
      @callbacks ||= {}
    end

    def callbacks_for(event_type)
      callbacks[event_type] ||= []
    end

    def receive(event)
      callbacks_for(event.type).each { |block| self.instance_exec(event, &block) }
    end
  end
end