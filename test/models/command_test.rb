require 'test_helper'

module PushyResources

  class CommandTest < ActiveSupport::TestCase

    def setup
      @websocket = MockWebsocket.new
    end

    test "it is created with a hash" do
      command = Command.new @websocket, :command => 'subscribe', :channel => 'test'

      assert_equal :subscribe, command.name
      assert_equal 'test', command.channel.name
    end

    test "subscribe to channel when subscribe command is executed" do
      channel = Channel['test']
      assert_equal channel.subscribers.size, 0

      command = Command.new @websocket, :command => 'subscribe', :channel => 'test'
      command.execute!

      assert_equal 1, channel.subscribers.size
    end
  end
end