require 'test_helper'

module PushyResources

  class ChatObserver < EventObserver
    observe '/chats/'

    def created_chats
      @created_chats ||= []
    end

    def subscribed_clients
      @subscribed_clients ||= []
    end

    on :created do |event|
      created_chats << event.resource
    end

    on :destroyed do |event|
      chat = event.resource
      created_chats.delete(chat)
    end

    on :subscribed do |event|
      subscribed_clients << event.resource
    end

    on :unsubscribed do |event|
      subscribed_clients.delete(event.resource)
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

    test 'observe subscribed clients' do
      user = Factory.create :user
      connection = MockConnection.new(:id => user.id)

      assert !ChatObserver.instance.subscribed_clients.include?(user)

      Command.new(connection, :command => 'subscribe', :channel => '/chats/').execute!

      sleep(0.1)

      assert ChatObserver.instance.subscribed_clients.include?(user)

      Command.new(connection, :command => 'unsubscribe', :channel => '/chats/').execute!

      sleep(0.1)

      assert !ChatObserver.instance.subscribed_clients.include?(user)
    end

  end
end