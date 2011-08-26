require 'test_helper'

module Alondra

  class CommandTest < ActiveSupport::TestCase

    def setup
      @connection = MockConnection.new
    end

    test "it is created with a connection and a hash" do
      command = Command.new @connection, :command => 'subscribe', :channel => 'test'

      assert_equal :subscribe, command.name
      assert_equal 'test', command.channel.name
    end

    test "subscribe to channel when subscribe command is executed" do
      channel = Channel['test']
      assert_equal 0, channel.connections.size

      command = Command.new @connection, :command => 'subscribe', :channel => 'test'
      command.execute!

      assert_equal 1, channel.connections.size
      assert channel.connections.keys.include? @connection
    end
  end
end