module Alondra
  class MockEventRouter

    def process(event)
      received_events << event
    end

    def received_events
      @received_events ||= []
    end
  end
end