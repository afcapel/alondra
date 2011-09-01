require 'test_helper'

module Alondra

  class ConnectionTest < ActiveSupport::TestCase

    test "it is assigned an UUI on creation" do
      assert MockConnection.new.uuid.present?
    end

    test "can find if there is a session" do
      session = {:user_id => 10}
      connection = MockConnection.new(session)

      assert_equal session, connection.session
    end
  end
end