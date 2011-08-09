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
        case PushyResources.config.event_queue
        when :redis then
          Rails.logger.info "selected Redis event queue"
          queue = RedisEventQueue.new
          queue.start if EM.reactor_thread?
          queue
        when :zeromq
          Rails.logger.info "selected ZeroMQ event queue"
          ZeromqEventQueue.new
        else
          Rails.logger.info "selected in memory event queue"
          EventQueue.new
        end
      end
    end

    def send(event)
      raise NoMethodError.new('The selected event queue must implement a send method')
    end
  end
end

