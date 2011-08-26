require 'test_helper'

module Alondra

  class PushingTest < ActiveSupport::TestCase

    test "publish created events to the specified channel" do
      chat       = Factory.create :chat
      connection = MockConnection.new
      message = chat.messages.build(:text => 'test message')

      channel_name = Channel.default_name_for(chat)
      assert channel_name =~ /chats\/\d+/

      channel    = Channel[channel_name]
      channel.subscribe connection

      sleep(0.1)

      message.save!

      sleep(0.1)

      assert connection.messages.last, "should publish a message"

      last_event = ActiveSupport::JSON.decode(connection.messages.last)
      resource   = last_event['resource']

      assert_equal 'created', last_event['event']
      assert_equal 'Message', last_event['resource_type']
      assert_equal message.id, resource['id']
    end
  end
end