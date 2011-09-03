module Alondra
  class EventRouter

    def self.listeners
      @listeners ||= []
    end

    def process(event)
      event.channel.receive(event)

      EM.defer do
        listening_classes = EventRouter.listeners.select do |ob|
          ob.listen_to?(event.channel_name)
        end
        listening_classes.each { |listening_class| listening_class.process(event) }
      end
    end
  end
end