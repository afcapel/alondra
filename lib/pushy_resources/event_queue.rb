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
        if RedisEventQueue.can_connect_to_redis?
          puts "selected redis queue"
          queue = RedisEventQueue.new
          queue.start
          queue
        else
          puts "selected in memory queue"
          EventQueue.new
        end
      end
    end

    def send(event)
      event.channel.receive(event)
    end
  end
end

