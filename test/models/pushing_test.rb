require 'test_helper'

module PushyResources

  class ChannelTest < ActiveSupport::TestCase

    def setup
      @websocket  = MockWebsocket.new
      @channel    = Channel['/messages/']

      @channel.subscribe @websocket
    end

    test "publish created events" do
      chat = Factory.create :chat
      message = chat.messages.create(:text => 'test message')

      sleep(1)

      last_event = ActiveSupport::JSON.decode(@websocket.messages.last)
      assert_equal 'created', last_event['event']
      assert_equal message.id, last_event['resource']['id']
    end

  end
end