require 'test_helper'

module Alondra

  class MessageQueuePerformanceTest < ActiveSupport::TestCase

    NUM_MESSAGES = 1_000

    setup do
      @event = Event.new :event => :custom, :resource => Chat.new, :channel => '/chats/'

      # Initialize queue
      MessageQueueClient.push @event

      @original_event_router = MessageQueue.instance.send :event_router
      @router = MockEventRouter.new

      MessageQueue.instance.instance_variable_set :@event_router, @router
    end

    teardown do
      MessageQueue.instance.instance_variable_set :@event_router, @original_event_router
    end

    test "message queue performance" do
      puts "send #{NUM_MESSAGES} messages to queue"

      time = Benchmark.measure do
        NUM_MESSAGES.times do
          MessageQueueClient.async_instance.send_message @event
        end

        while @router.received_events.size < NUM_MESSAGES
          sleep(0.1)
        end
      end

      events_per_second = NUM_MESSAGES/time.total

      puts "aprox. received events per second #{events_per_second}"

      assert events_per_second >= 500
    end


    test "message queue performance with sync client" do
      puts "send #{NUM_MESSAGES} messages to queue"

      time = Benchmark.measure do
        NUM_MESSAGES.times do
          MessageQueueClient.sync_instance.send_message @event
        end

        while @router.received_events.size < NUM_MESSAGES
          sleep(0.1)
        end
      end

      events_per_second = NUM_MESSAGES/time.total

      puts "aprox. received events per second #{events_per_second}"

      assert events_per_second >= 500
    end
  end
end