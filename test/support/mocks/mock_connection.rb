module Alondra
  class MockConnection < Connection

    def initialize(session = {})
      super UUIDTools::UUID.random_create, session
    end

    def send(message)
      messages << message
    end

    def receive(event)
      messages << event.to_json
    end

    def channels
      @channels ||= []
    end

    def messages
      @messages ||= []
    end
  end
end