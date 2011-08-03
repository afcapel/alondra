require 'test_helper'

module PushyResources

  class ChannelTest < ActiveSupport::TestCase

    def setup
      @connection = MockConnection.new
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
      channel   = Channel.new('test subscriptions channel')
      assert_equal 0, channel.connections.size

      channel.subscribe @connection

      assert_equal 1, channel.connections.size
    end

    test "deliver events to all subscribed connections" do
      channel   = Channel.new('test deliver events channel')
      channel.subscribe @connection

      event = Event.new :event => :created, :resource => Chat.new, :channel => 'test deliver events channel'

      channel.receive event

      assert EM.reactor_running?

      sleep(0.1) # Leave event machine to catch up

      last_message = @connection.messages.last
      assert_equal event.to_json, last_message
    end

    test "it list the users subscribed to a channel" do
      john = Factory.create :user
      jane = Factory.create :user

      john_connection = MockConnection.new(:id => john.id)
      jane_connection = MockConnection.new(:id => jane.id)
      another_jane_connection = MockConnection.new(:id => jane.id)

      assert_equal john, john_connection.user
      assert_equal jane, jane_connection.user

      channel = Channel['/subscriptions/']

      channel.subscribe @connection
      channel.subscribe john_connection
      channel.subscribe jane_connection
      channel.subscribe another_jane_connection

      assert_equal 2, channel.users.size

      assert channel.users.include? john
      assert channel.users.include? jane
    end
  end
end