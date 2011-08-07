module PushyResources
  class EventRouter
    include Singleton

    def observers
      @observers ||= []
    end

    def self.process(event)
      puts "processing event #{event.to_json}"
      event.channel.receive(event)

      observing_classes = instance.observers.select { |ob| ob.observe?(event.channel_name) }
      observing_classes.each do |observer_class|
        new_instance = observer_class.new
        new_instance.receive(event)
      end
    end
  end
end