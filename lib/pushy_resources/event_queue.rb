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
          Rails.logger.info "selected Redis event queue"
          queue = RedisEventQueue.new
          queue.start if EM.reactor_thread?
          queue
        else
          Rails.logger.info "selected in memory event queue"
          EventQueue.new
        end
      end
    end

    def send(event)
      EventRouter.process(event)
    end
  end
end

