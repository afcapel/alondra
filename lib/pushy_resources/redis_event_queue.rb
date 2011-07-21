module PushyResources
  class RedisEventQueue

    class << self
      def can_connect_to_redis?
        # TODO: perform real test
        true
      end

      def redis
        # We need two redis clients since redis synchronize access to its client
        # Otherwise reactor and application threads will end in a deadlock

        # Furthermore we can't use a blocking driver inside EventMachine
        # and a non-blocking driver in a regular rails applicartion, so we must
        # choose the right driver in each case

        if EM.reactor_thread?
          @reactor_redis_client ||= reactor_redis_client
        else
          @app_redis_client     ||=  app_redis_client
        end
      end

      def reactor_redis_client
        # Force redis to use synchrony driver
        Thread.exclusive do
          require 'redis/connection/synchrony'
          Redis::Connection.drivers << Redis::Connection::Synchrony
          @reactor_redis_client = Redis.new
        end
      end

      def app_redis_client
        # Force redis to use ruby driver
        Thread.exclusive do
          require 'redis/connection/ruby'
          Redis::Connection.drivers << Redis::Connection::Ruby
          @app_redis_client = Redis.new
        end
      end


      def redis_channel
        'PushyEvents'
      end
    end

    def start
      return unless EM.reactor_thread?

      RedisEventQueue.redis.psubscribe RedisEventQueue.redis_channel do |subscription|
        subscription.pmessage do |pattern, event, message|
          event = Event.from_json(message)
          process(event)
        end
      end
    end

    def send(event)
      serialized_event = event.to_json
      RedisEventQueue.redis.publish RedisEventQueue.redis_channel, serialized_event
    end

    def process(event)
      event.channel.receive(event)
    end
  end
end