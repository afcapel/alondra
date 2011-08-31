require 'test_helper'

module Alondra

  class EventQueuePerformanceTest < ActiveSupport::TestCase
    setup do
      @original_event_router = EventQueue.instance.send :event_router
      @router = MockEventRouter.new

      EventQueue.instance.instance_variable_set :@event_router, @router
      @event = Event.new :event => :custom, :resource => Chat.new, :channel => '/chats/'
    end

    teardown do
      EventQueue.instance.instance_variable_set :@event_router, @original_event_router
    end

    test "event queue performance" do
      puts "send 1000 messages to queue"

      1000.times do
        EventQueue.push @event
      end

      sleep(0.5)

      events_per_second = @router.received_events.size * 2

      puts "aprox. received events per second #{events_per_second}"

      assert events_per_second >= 500
    end


    test "zeromq socket performance" do
      puts "send 1000 messages to zeromq socket"

      socket = EventQueue.instance.send :push_socket
      json = @event.to_json

      1000.times do
        socket.send_msg json
      end

      sleep(0.5)

      events_per_second = @router.received_events.size * 2

      puts "aprox. received events per second skipping client serialization #{events_per_second}"

      assert events_per_second >= 500
    end

  end
end