require 'test_helper'

module Alondra

  class EventQueueTest < ActiveSupport::TestCase
    setup do
      @original_event_router = EventQueue.instance.send :event_router
      @router = MockEventRouter.new

      @chat = Chat.create(:name => 'Silly chat')

      EventQueue.instance.instance_variable_set :@event_router, @router
      @event = Event.new :event => :custom, :resource => @chat, :channel => '/chats/'
    end

    teardown do
      EventQueue.instance.instance_variable_set :@event_router, @original_event_router
    end

    test "a message pushed to the queue is received by the event router" do
      EventQueue.push @event

      sleep(0.1)

      last_event =  @router.received_events.last

      assert last_event.type == :custom
      assert last_event.resource_type == 'Chat'
      assert last_event.resource.id== @chat.id
      assert last_event.channel_name == '/chats/'
    end

    test "event queue still works when an exception is thrown while processing an event" do
      3.times do
        bogus = BogusEvent.new :event => :custom, :resource => @chat, :channel => '/chats/'

        begin
          EventQueue.push bogus
        rescue BogusException
          puts "rescued exception"
        end
      end

      EventQueue.push @event

      sleep(0.1)

      last_event =  @router.received_events.last

      assert last_event.type == :custom
      assert last_event.resource_type == 'Chat'
      assert last_event.resource.id == @chat.id
      assert last_event.channel_name == '/chats/'
    end
  end
end