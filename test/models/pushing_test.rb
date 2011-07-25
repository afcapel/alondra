require 'test_helper'

module PushyResources

  class PushingTest < ActiveSupport::TestCase

    def setup
      @connection = MockConnection.new
      @channel    = Channel['/messages/']

      @channel.subscribe @connection
    end

    test "publish created events" do
      chat = Factory.create :chat
      message = chat.messages.create(:text => 'test message')

      sleep(0.1)

      assert @connection.messages.last, "should publish a message"

      last_event = ActiveSupport::JSON.decode(@connection.messages.last)
      resource   = last_event['resource']

      assert_equal 'created', last_event['event']
      assert_equal 'Message', last_event['resource_type']
      assert_equal message.id, resource['id']
    end

  end
end