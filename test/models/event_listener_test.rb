require 'test_helper'

module Alondra

  class ChatListener < EventListener

    def self.created_chats
      @created_chats ||= []
    end

    def self.subscribed_user_ids
      @subscribed_user_ids ||= []
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
      ChatListener.subscribed_user_ids << session[:user_id]
    end

    on :unsubscribed do |event|
      ChatListener.subscribed_user_ids.delete(session[:user_id])
    end

    on :subscribed, :to => :collection do |event|
      ChatListener.subscribed_to_collection << session[:user_id]
    end

    on :unsubscribed, :to => :collection do |event|
      ChatListener.subscribed_to_collection.delete(session[:user_id])
    end

    on :subscribed, :to => :member do |event|
      ChatListener.subscribed_to_member << session[:user_id]
    end

    on :unsubscribed, :to => :member do |event|
      ChatListener.subscribed_to_member.delete(session[:user_id])
    end

    on :custom do |event|
      ChatListener.custom_events << event
    end

    on :boom do |event|
      event.boom!
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
      session = {:user_id => 28 }
      connection = MockConnection.new(session)

      assert !ChatListener.subscribed_user_ids.include?(28)

      Command.new(connection, :command => 'subscribe', :channel => '/chats/').execute!

      sleep(0.1)

      assert ChatListener.subscribed_user_ids.include?(28)

      Command.new(connection, :command => 'unsubscribe', :channel => '/chats/').execute!

      sleep(0.1)

      assert !ChatListener.subscribed_user_ids.include?(28)
    end

    test 'react to subscribed and unsubscribed events on collection' do
      session = {:user_id => 29 }
      connection = MockConnection.new(session)

      assert !ChatListener.subscribed_to_collection.include?(29)
      assert !ChatListener.subscribed_to_member.include?(29)

      Command.new(connection, :command => 'subscribe', :channel => '/chats/').execute!

      sleep(0.1)

      assert ChatListener.subscribed_to_collection.include?(29)
      assert !ChatListener.subscribed_to_member.include?(29)

      Command.new(connection, :command => 'unsubscribe', :channel => '/chats/').execute!

      sleep(0.1)

      assert !ChatListener.subscribed_to_collection.include?(29)
      assert !ChatListener.subscribed_to_member.include?(29)
    end

    test 'react to subscribed and unsubscribed events on member' do
      session = {:user_id => 30 }
      connection = MockConnection.new(session)

      chat = Factory.create :chat

      chat_channel = "/chats/#{chat.id}"

      assert !ChatListener.subscribed_to_collection.include?(30)
      assert !ChatListener.subscribed_to_member.include?(30)

      Command.new(connection, :command => 'subscribe', :channel => chat_channel).execute!

      sleep(0.1)

      assert !ChatListener.subscribed_to_collection.include?(30)
      assert ChatListener.subscribed_to_member.include?(30)

      Command.new(connection, :command => 'unsubscribe', :channel => chat_channel).execute!

      sleep(0.1)

      assert !ChatListener.subscribed_to_collection.include?(30)
      assert !ChatListener.subscribed_to_member.include?(30)
    end

    test 'receive customs events' do
      event = Event.new :event => :custom, :resource => Chat.new, :channel => '/chats/'
      EventRouter.new.process(event)

      assert_equal ChatListener.custom_events.last, event
    end

    test 'capture exceptions launched in event listener' do
      boom = BogusEvent.new :event => :boom, :resource => Chat.new, :channel => '/chats/'
      EventRouter.new.process(boom)

      event = Event.new :event => :custom, :resource => Chat.new, :channel => '/chats/'
      EventRouter.new.process(event)

      assert_equal ChatListener.custom_events.last, event
    end
  end
end