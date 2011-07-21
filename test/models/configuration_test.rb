require 'test_helper'

module PushyResources

  class ConfigurationTest < ActiveSupport::TestCase

    def setup
      PushyResources.config do
        redis_host    'www.example.com'
        test_variable 'something'
      end
    end

    test "it has default values" do
      assert_equal :redis, PushyResources.config(:event_queue)
    end

    test "it allows to override default values" do
      assert_equal 'www.example.com', PushyResources.config(:redis_host)
    end

    test "it allows to define new variables" do
      assert_equal 'something', PushyResources.config(:test_variable)
    end
  end
end