module PushyResources
  class EventQueue

    class << self
      def push(event)
        selected_queue.send(event)
      end

      def selected_queue
        @selected_queue ||= select_queue
      end

      def select_queue
        if PushyResources.config.event_queue == :redis
          queue = RedisEventQueue.new
          queue.start
          queue
        else
          EventQueue.new
        end
      end
    end

    def send(event)
      event.channel.receive(event)
    end
  end
end

