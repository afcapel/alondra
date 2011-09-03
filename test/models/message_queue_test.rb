require 'test_helper'

module Alondra

  class MessageQueueTest < ActiveSupport::TestCase
    setup do
      @original_event_router = MessageQueue.instance.send :event_router
      @router = MockEventRouter.new

      @chat = Chat.create(:name => 'Silly chat')

      MessageQueue.instance.instance_variable_set :@event_router, @router
      @event = Event.new :event => :custom, :resource => @chat, :channel => '/chats/'
    end

    teardown do
      MessageQueue.instance.instance_variable_set :@event_router, @original_event_router
    end

    test "a message pushed asynchronously to the queue is received by the event router" do
      assert MessageQueueClient.instance.class == AsyncMessageQueueClient

      MessageQueueClient.push @event

      sleep(0.1)

      assert received(@event)
    end

    test "a message pushed synchronously to the queue is received by the event router" do

      client = MessageQueueClient.sync_instance
      context = client.send :context
      assert context.class == ZMQ::Context

      client.send_message(@event)

      sleep(0.1)

      assert received(@event)
    end

    test "message queue still works when an exception is thrown while processing an event" do
      3.times do
        bogus = BogusEvent.new :event => :custom, :resource => @chat, :channel => '/chats/'

        begin
          MessageQueueClient.push bogus
        rescue BogusException
          puts "rescued exception"
        end
      end

      MessageQueueClient.push @event

      sleep(0.1)

      assert received(@event)
    end

    def received(event)
      @router.received_events.find do |matching_event|
        matching_event.type == event.type &&
        matching_event.resource_type == event.resource_type &&
        matching_event.resource.id == event.resource.id &&
        matching_event.channel_name == event.channel_name
      end
    end
  end
end