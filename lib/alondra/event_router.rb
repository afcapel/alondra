module Alondra
  class EventRouter

    def self.listeners
      @listeners ||= []
    end

    def process(event)
      event.channel.receive(event)

      self.class.listeners.each do |listener|
        next unless listener.listen_to?(event.channel_name)
        new_instance = listener.new
        new_instance.receive(event)
      end
    end
  end
end