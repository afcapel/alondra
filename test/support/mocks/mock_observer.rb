class MockObserver
  def received_events
    @received_events ||= []
  end

  def receive(event)
    received_events << event
  end
end