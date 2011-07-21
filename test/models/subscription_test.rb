require 'test_helper'

module PushyResources

  class SubscriptionTest < ActiveSupport::TestCase
    test "it has an associated user if initialized with credentials" do
      user       = Factory.create :user
      websocket  = MockWebsocket.new
      channel    = Channel['/subscriptions/']

      subscription = Subscription.new(channel, websocket, :user_id => user.id)
      assert_equal user, subscription.user
    end
  end
end