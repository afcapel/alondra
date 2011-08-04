module PushyResources
  class ObserverCallback
    attr_reader :event_type
    attr_reader :options
    attr_reader :proc

    def initialize(event_type, options = {}, proc)
      @event_type = event_type
      @options    = options
      @proc       = proc
    end

    def matches?(event)
      return false unless event.type == event_type

      case options[:to]
      when nil then true
      when :member then
        event.resource.present?
      when :collection then
        event.resource.blank?
      end
    end
  end
end