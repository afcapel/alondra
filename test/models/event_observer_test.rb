require 'test_helper'

module PushyResources

  class ChatObserver < EventObserver
    observe '/chats/'

    def created_chats
      @created_chats ||= []
    end

    on :created do |event|
      created_chats << event.resource
    end

    on :destroyed do |event|
      chat = event.resource
      created_chats.delete(chat)
    end

  end


  class EventObserverTest < ActiveSupport::TestCase

    test 'observe a channel' do
      chat = Chat.create :name => 'Observed chat'

      sleep(0.1)

      assert ChatObserver.instance.created_chats.include?(chat)

      chat.destroy

      sleep(0.1)

      assert !ChatObserver.instance.created_chats.include?(chat)
    end

  end
end