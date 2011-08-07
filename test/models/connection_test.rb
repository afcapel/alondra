require 'test_helper'

module PushyResources

  class ConnectionTest < ActiveSupport::TestCase

    test "it is assigned an UUI on creation" do
      assert MockConnection.new.uuid.present?
    end

    test "can find user if credentials are provided" do
      user = Factory.create :user
      connection = MockConnection.new(:user_id => user.id)

      assert_equal user, connection.user
    end
  end
end