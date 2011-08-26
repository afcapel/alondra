require 'test_helper'

module Alondra

  class EventQueueTest < ActiveSupport::TestCase

    test "a message pushed to the queue is received by the event router" do

    end

    test "event queue still works when an exception is thrown at the middle of an event processing" do
    end

  end
end