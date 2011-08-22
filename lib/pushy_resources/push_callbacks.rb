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
      channels = channels_from(type, record, options)

      channels.each do |channel|
        event = Event.new(:event => type, :resource => record, :channel => channel)
        EventQueue.push event
      end
    end

    def channels_from(type, record, options)
      case options[:to]
      when String then
        [options[:to]]
      when Symbol then
        recipients = record.send options[:to]

        if Enumerable === recipients
          recipients.collect { |r| Channel.default_name_for(r) }
        else
          [Channel.default_name_for(recipients)]
        end
      else
        [Channel.default_name_for(record)]
      end
    end
  end
end