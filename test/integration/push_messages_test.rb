require 'test_helper'

module PushyResources
  class PushMessagesTest < ActiveSupport::IntegrationCase
    self.use_transactional_fixtures = false

    setup do
      clean_db
      Capybara.default_driver = :webkit
    end

    teardown do
      clean_db
    end

    test "execute messages in client" do
      self.extend Pushing

      @user = Factory.create :user
      @text = 'hola!'

      chat = Factory.create :chat, :name => 'A chat to receive messages'

      login_as @user

      chat_path = chat_path(chat)
      visit chat_path(chat)

      wait_until 10 do
        page.has_content? 'Subscribed to channel'
      end

      push :partial => '/shared/message', :to => chat_path

      wait_until 20 do
        page.has_content? "#{@user.username} says hola!"
      end
    end
  end
end