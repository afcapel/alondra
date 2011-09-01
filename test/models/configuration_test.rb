require 'test_helper'

module Alondra

  class ConfigurationTest < ActiveSupport::TestCase

    test "it has default values" do
      assert_equal 12346, Alondra.config.port
    end

    test "it allows to override default values" do
      assert_equal 'localhost', Alondra.config.host
      Alondra.config.host    = 'www.example.com'
      assert_equal 'www.example.com', Alondra.config.host
    end

    test "it allows to define new variables" do
      Alondra.config.test_variable = 'something'
      assert_equal 'something', Alondra.config.test_variable
    end
  end
end