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
      resource   = ActiveSupport::JSON.decode(last_event['resource'])

      assert_equal 'created', last_event['event']
      assert_equal 'Message', last_event['resource_type']
      assert_equal message.id, resource['id']
    end

  end
end