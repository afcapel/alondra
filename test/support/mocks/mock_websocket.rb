module PushyResources
  class MockWebsocket

    def send(message)
      messages << message
    end

    def messages
      @messages ||= []
    end
  end
end