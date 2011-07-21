require 'test_helper'

module PushyResources

  class ChannelTest < ActiveSupport::TestCase

    def setup
      @websocket = MockWebsocket.new
    end

    test "it has a name" do
      channel   = Channel.new('test name channel')
      assert_equal 'test name channel', channel.name
    end

    test "can fetch channel by name" do
      channel = Channel['dummy channel']
      assert_equal 'dummy channel', channel.name
    end

    test "allow clients to subscribe" do
      channel   = Channel.new('test subscribers channel')
      assert_equal 0, channel.subscribers.size

      channel.subscribe @websocket

      assert_equal 1, channel.subscribers.size
    end

    test "deliver events to all subscribed clients" do
      channel   = Channel.new('test deliver events channel')
      subscriber = channel.subscribe @websocket

      event = Event.new :event => :created, :resource => Chat.new, :channel => 'test deliver events channel'

      channel.receive event

      assert EM.reactor_running?

      sleep(0.1) # Leave event machine to catch up

      last_message = subscriber.websocket.messages.last
      assert_equal event.to_json, last_message
    end

    test "it list the users subscribed to a channel" do
      john = Factory.create :user
      jane = Factory.create :user

      channel = Channel['/subscribers/']

      channel.subscribe @websocket, :user_id => john.id
      channel.subscribe @websocket, :user_id => jane.id
      channel.subscribe @websocket, :user_id => john.id

      assert_equal 2, channel.users.size

      assert channel.users.include? john
      assert channel.users.include? jane
    end

  end
end