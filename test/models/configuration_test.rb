require 'test_helper'

module PushyResources

  class ConfigurationTest < ActiveSupport::TestCase

    test "it has default values" do
      assert_equal :memory, PushyResources.config.event_queue
    end

    test "it allows to override default values" do
      PushyResources.config.redis_host    = 'www.example.com'
      assert_equal 'www.example.com', PushyResources.config.redis_host
    end

    test "it allows to define new variables" do
      PushyResources.config.test_variable = 'something'
      assert_equal 'something', PushyResources.config.test_variable
    end
  end
end