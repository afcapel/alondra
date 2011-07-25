module PushyResources
  class MockConnection < Connection

    def initialize(credentials = nil)
      super nil, credentials
    end

    def send(message)
      messages << message
    end

    def receive(event)
      messages << event.to_json
    end

    def messages
      @messages ||= []
    end
  end
end