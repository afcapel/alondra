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
        EventQueue.new
      end
    end

    def send(event)
      event.channel.receive(event)
    end
  end
end

