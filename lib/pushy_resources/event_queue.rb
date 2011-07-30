module PushyResources
  class EventQueue

    class << self
      def push(event)
        selected.send(event)
      end

      def selected
        @selected ||= select
      end

      def select
        if PushyResources.config.event_queue == :redis
          puts "selected Redis event queue"
          queue = RedisEventQueue.new
          queue.start
          queue
        else
          puts "selected in memory event queue"
          EventQueue.new
        end
      end
    end

    def send(event)
      event.channel.receive(event)
      observers_for(event.channel_name).each { |ob| ob.receive(event) }
    end
  end
end

