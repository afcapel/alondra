require 'test_helper'

module Alondra

  class ChatObserver < EventListener

    def self.created_chats
      @created_chats ||= []
    end

    def self.subscribed_clients
      @subscribed_clients ||= []
    end

    def self.subscribed_to_collection
      @subscribed_to_collection ||= []
    end

    def self.subscribed_to_member
      @subscribed_to_member ||= []
    end

    def self.custom_events
      @custom_events ||= []
    end

    on :created do |event|
      ChatObserver.created_chats << event.resource
    end

    on :destroyed do |event|
      chat = event.resource
      ChatObserver.created_chats.delete(chat)
    end

    on :subscribed do |event|
      ChatObserver.subscribed_clients << event.resource
    end

    on :unsubscribed do |event|
      ChatObserver.subscribed_clients.delete(event.resource)
    end

    on :subscribed, :to => :collection do |event|
      ChatObserver.subscribed_to_collection << event.resource
    end

    on :unsubscribed, :to => :collection do |event|
      ChatObserver.subscribed_to_collection.delete(event.resource)
    end

    on :subscribed, :to => :member do |event|
      ChatObserver.subscribed_to_member << event.resource
    end

    on :unsubscribed, :to => :member do |event|
      ChatObserver.subscribed_to_member.delete(event.resource)
    end

    on :custom do |event|
      ChatObserver.custom_events << event
    end

  end


  class EventListenerTest < ActiveSupport::TestCase

    test "can listen to a specific channel providing a string pattern" do
      class TextPatternObserver < EventListener
        listen_to 'string pattern'
      end

      assert  TextPatternObserver.listen_to?('string pattern')
      assert  TextPatternObserver.listen_to?('string pattern and more')
      assert !TextPatternObserver.listen_to?('other string pattern')
    end

    test "can listen to specific channel providing a regexp as pattern" do
      class RegexpPatternObserver < EventListener
        listen_to /man$/
      end

      assert  RegexpPatternObserver.listen_to?('Superman')
      assert !RegexpPatternObserver.listen_to?('Lex Luthor')
    end

    test "it has a default channel pattern" do
      class DefaultPatternsObserver < EventListener; end

      assert  DefaultPatternsObserver.listen_to?('/default/patterns/')
      assert  DefaultPatternsObserver.listen_to?('/default/patterns/1')

      assert !DefaultPatternsObserver.listen_to?('/default/other/')
      assert !DefaultPatternsObserver.listen_to?('/other/patterns/')
    end

    test "default channel pattern is ignored if explicit listen_to pattern is called" do
      class OverwrittenDefaultPatternsObserver < EventListener
        listen_to '/others'
      end

      assert  OverwrittenDefaultPatternsObserver.listen_to?('/others')
      assert  OverwrittenDefaultPatternsObserver.listen_to?('/others/1/')
      assert !OverwrittenDefaultPatternsObserver.listen_to?('/overwritten/default/patterns')
    end


    test 'receive created and destroyes events' do
      ChatObserver.listen_to '/chats/'

      chat = Chat.create :name => 'Observed chat'

      sleep(0.1)

      assert ChatObserver.created_chats.include?(chat)

      chat.destroy

      sleep(0.1)

      assert !ChatObserver.created_chats.include?(chat)
    end

    test 'react to subscribed and unsubscribed events' do
      user = Factory.create :user
      connection = MockConnection.new(:id => user.id)

      assert !ChatObserver.subscribed_clients.include?(user)

      Command.new(connection, :command => 'subscribe', :channel => '/chats/').execute!

      EM.reactor_thread.join(2.5)

      assert ChatObserver.subscribed_clients.include?(user)

      Command.new(connection, :command => 'unsubscribe', :channel => '/chats/').execute!

      EM.reactor_thread.join(2.5)

      assert !ChatObserver.subscribed_clients.include?(user)
    end

    test 'react to subscribed and unsubscribed events on collection' do
      user = Factory.create :user
      connection = MockConnection.new(:id => user.id)

      assert !ChatObserver.subscribed_to_collection.include?(user)
      assert !ChatObserver.subscribed_to_member.include?(user)

      Command.new(connection, :command => 'subscribe', :channel => '/chats/').execute!

      sleep(0.1)

      assert ChatObserver.subscribed_to_collection.include?(user)
      assert !ChatObserver.subscribed_to_member.include?(user)

      Command.new(connection, :command => 'unsubscribe', :channel => '/chats/').execute!

      sleep(0.1)

      assert !ChatObserver.subscribed_to_collection.include?(user)
      assert !ChatObserver.subscribed_to_member.include?(user)
    end

    test 'react to subscribed and unsubscribed events on member' do
      user = Factory.create :user
      connection = MockConnection.new(:id => user.id)
      chat = Factory.create :chat

      chat_channel = "/chats/#{chat.id}"

      assert !ChatObserver.subscribed_to_collection.include?(user)
      assert !ChatObserver.subscribed_to_member.include?(user)

      Command.new(connection, :command => 'subscribe', :channel => chat_channel).execute!

      sleep(0.1)

      assert !ChatObserver.subscribed_to_collection.include?(user)
      assert ChatObserver.subscribed_to_member.include?(user)

      Command.new(connection, :command => 'unsubscribe', :channel => chat_channel).execute!

      sleep(0.1)

      assert !ChatObserver.subscribed_to_collection.include?(user)
      assert !ChatObserver.subscribed_to_member.include?(user)
    end

    test 'receive customs events' do
      event = Event.new :event => :custom, :resource => Chat.new, :channel => '/chats/'
      EventRouter.new.process(event)

      assert_equal ChatObserver.custom_events.last, event
    end
  end
end