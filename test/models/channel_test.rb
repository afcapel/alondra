require 'test_helper'

module Alondra

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
      assert channel.connections.keys.include? @connection
    end

    test "deliver events to all subscribed connections" do
      channel   = Channel.new('test deliver events channel')
      channel.subscribe @connection

      assert @connection.channels.include?(channel)

      event = Event.new :event => :created, :resource => Chat.new, :channel => 'test deliver events channel'

      channel.receive event

      assert EM.reactor_running?

      sleep(0.1) # Leave event machine to catch up

      last_message = @connection.messages.last
      assert_equal event.to_json, last_message
    end
  end
end