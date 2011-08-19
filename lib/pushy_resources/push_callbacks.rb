module PushyResources
  module PushCallbacks
    extend self

    def push_updates(klass, options)
      klass.class_eval do
        after_update do |record|
          PushCallbacks.push_event :updated, record, options
        end
      end
    end

    def push_creations(klass, options)
      klass.class_eval do
        after_create do |record|
          PushCallbacks.push_event :created, record, options
        end
      end
    end

    def push_destroys(klass, options)
      klass.class_eval do
        after_destroy do |record|
          PushCallbacks.push_event :destroyed, record, options
        end
      end
    end

    def push_event(type, record, options)
      event_attrs = { :event => type, :resource => record }

      channel = channel_from(record, options)

      event_attrs.merge! :channel => channel if channel

      event = Event.new(event_attrs)
      EventQueue.push event
    end

    def channel_from(record, options)
      case options[:to]
      when String then
        options[:to]
      when Symbol then
        target = record.send options[:to]
        Channel.default_name_for(:updated, target)
      else
        nil
      end
    end
  end
end