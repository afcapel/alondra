require 'test_helper'

module Alondra

  class MessageQueueClientTest < ActiveSupport::TestCase

    test "a sync client uses a sync zeromq context" do
      context = SyncMessageQueueClient.new.send :context
      assert context.class == ZMQ::Context
    end

    test "an async client uses an async zeromq context" do
      context = nil

      assert EM.reactor_running?

      EM.schedule do
        context = MessageQueueClient.instance.send :context
      end

      sleep(0.1)

      assert context.class == EM::ZeroMQ::Context
    end
  end
end