require 'test_helper'

class NavigationTest < ActiveSupport::IntegrationCase
  test "a client can subscribe to channel presences" do
    chat = Factory.create :chat
    chat_path = chat_path(chat)

    chat_channel = PushyResources::Channel[chat_path]
    assert_equal 0, chat_channel.subscriptions.size

    visit chat_path
  end
end