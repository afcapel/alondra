require 'test_helper'

module PushyResources

  class ConfigurationTest < ActiveSupport::TestCase

    test "it has default values" do
      assert_equal 12345, PushyResources.config.port
    end

    test "it allows to override default values" do
      assert_equal 'localhost', PushyResources.config.host
      PushyResources.config.host    = 'www.example.com'
      assert_equal 'www.example.com', PushyResources.config.host
    end

    test "it allows to define new variables" do
      PushyResources.config.test_variable = 'something'
      assert_equal 'something', PushyResources.config.test_variable
    end
  end
end