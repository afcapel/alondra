module Alondra
  class EventRouter

    def self.listeners
      @listeners ||= []
    end

    def process(event)
      event.channel.receive(event)

      listening_classes = EventRouter.listeners.select { |ob| ob.listen_to?(event.channel_name) }

      listening_classes.each do |listening_class|
        new_instance = listening_class.new
        new_instance.receive(event)
      end
    end
  end
end