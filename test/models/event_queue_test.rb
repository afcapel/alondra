require 'test_helper'

module PushyResources

  class RedisEventQueueTest < ActiveSupport::TestCase

    test "an event pushed to the queue is received by the event router" do
    end

    test "event queue still works when an exception is thrown at the middle of an event processing" do
    end

  end
end