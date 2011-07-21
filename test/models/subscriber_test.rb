require 'test_helper'

module PushyResources

  class SubscriberTest < ActiveSupport::TestCase
    test "it has an associated user if initialized with credentials" do
      user       = Factory.create :user
      websocket  = MockWebsocket.new
      channel    = Channel['/subscribers/']

      subscriber = Subscriber.new(channel, websocket, :user_id => user.id)
      assert_equal user, subscriber.user
    end
  end
end