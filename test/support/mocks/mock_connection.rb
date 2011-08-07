module PushyResources
  class MockConnection < Connection

    def initialize(credentials = {})
      super nil, credentials
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