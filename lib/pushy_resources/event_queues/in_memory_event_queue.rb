module PushyResources
  class InMemoryEventQueue < EventQueue
    def send(event)
      EventRouter.process(event)
    end
  end
end
