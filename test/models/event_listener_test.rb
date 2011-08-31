require 'test_helper'

module Alondra

  class ChatListener < EventListener

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
      ChatListener.created_chats << event.resource
    end

    on :destroyed do |event|
      chat = event.resource
      ChatListener.created_chats.delete(chat)
    end

    on :subscribed do |event|
      ChatListener.subscribed_clients << event.resource
    end

    on :unsubscribed do |event|
      ChatListener.subscribed_clients.delete(event.resource)
    end

    on :subscribed, :to => :collection do |event|
      ChatListener.subscribed_to_collection << event.resource
    end

    on :unsubscribed, :to => :collection do |event|
      ChatListener.subscribed_to_collection.delete(event.resource)
    end

    on :subscribed, :to => :member do |event|
      ChatListener.subscribed_to_member << event.resource
    end

    on :unsubscribed, :to => :member do |event|
      ChatListener.subscribed_to_member.delete(event.resource)
    end

    on :custom do |event|
      ChatListener.custom_events << event
    end

  end


  class EventListenerTest < ActiveSupport::TestCase

    test "can listen to a specific channel providing a string pattern" do
      class TextPatternListener < EventListener
        listen_to 'string pattern'
      end

      assert  TextPatternListener.listen_to?('string pattern')
      assert  TextPatternListener.listen_to?('string pattern and more')
      assert !TextPatternListener.listen_to?('other string pattern')
    end

    test "can listen to specific channel providing a regexp as pattern" do
      class RegexpPatternListener < EventListener
        listen_to /man$/
      end

      assert  RegexpPatternListener.listen_to?('Superman')
      assert !RegexpPatternListener.listen_to?('Lex Luthor')
    end

    test "it has a default channel pattern" do
      class DefaultPatternsListener < EventListener; end

      assert  DefaultPatternsListener.listen_to?('/default/patterns/')
      assert  DefaultPatternsListener.listen_to?('/default/patterns/1')

      assert !DefaultPatternsListener.listen_to?('/default/other/')
      assert !DefaultPatternsListener.listen_to?('/other/patterns/')
    end

    test "default channel pattern is ignored if explicit listen_to pattern is called" do
      class OverwrittenDefaultPatternsListener < EventListener
        listen_to '/others'
      end

      assert  OverwrittenDefaultPatternsListener.listen_to?('/others')
      assert  OverwrittenDefaultPatternsListener.listen_to?('/others/1/')
      assert !OverwrittenDefaultPatternsListener.listen_to?('/overwritten/default/patterns')
    end


    test 'receive created and destroyes events' do
      ChatListener.listen_to '/chats/'

      chat = Chat.create :name => 'Observed chat'

      sleep(0.1)

      assert ChatListener.created_chats.include?(chat)

      chat.destroy

      sleep(0.1)

      assert !ChatListener.created_chats.include?(chat)
    end

    test 'react to subscribed and unsubscribed events' do
      user = Factory.create :user
      connection = MockConnection.new(:id => user.id)

      assert !ChatListener.subscribed_clients.include?(user)

      Command.new(connection, :command => 'subscribe', :channel => '/chats/').execute!

      EM.reactor_thread.join(2.5)

      assert ChatListener.subscribed_clients.include?(user)

      Command.new(connection, :command => 'unsubscribe', :channel => '/chats/').execute!

      EM.reactor_thread.join(2.5)

      assert !ChatListener.subscribed_clients.include?(user)
    end

    test 'react to subscribed and unsubscribed events on collection' do
      user = Factory.create :user
      connection = MockConnection.new(:id => user.id)

      assert !ChatListener.subscribed_to_collection.include?(user)
      assert !ChatListener.subscribed_to_member.include?(user)

      Command.new(connection, :command => 'subscribe', :channel => '/chats/').execute!

      sleep(0.1)

      assert ChatListener.subscribed_to_collection.include?(user)
      assert !ChatListener.subscribed_to_member.include?(user)

      Command.new(connection, :command => 'unsubscribe', :channel => '/chats/').execute!

      sleep(0.1)

      assert !ChatListener.subscribed_to_collection.include?(user)
      assert !ChatListener.subscribed_to_member.include?(user)
    end

    test 'react to subscribed and unsubscribed events on member' do
      user = Factory.create :user
      connection = MockConnection.new(:id => user.id)
      chat = Factory.create :chat

      chat_channel = "/chats/#{chat.id}"

      assert !ChatListener.subscribed_to_collection.include?(user)
      assert !ChatListener.subscribed_to_member.include?(user)

      Command.new(connection, :command => 'subscribe', :channel => chat_channel).execute!

      sleep(0.1)

      assert !ChatListener.subscribed_to_collection.include?(user)
      assert ChatListener.subscribed_to_member.include?(user)

      Command.new(connection, :command => 'unsubscribe', :channel => chat_channel).execute!

      sleep(0.1)

      assert !ChatListener.subscribed_to_collection.include?(user)
      assert !ChatListener.subscribed_to_member.include?(user)
    end

    test 'receive customs events' do
      event = Event.new :event => :custom, :resource => Chat.new, :channel => '/chats/'
      EventRouter.new.process(event)

      assert_equal ChatListener.custom_events.last, event
    end
  end
end