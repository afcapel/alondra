module Alondra
  module ChangesCallbacks
    extend self

    def push_updates(klass, options)
      klass.class_eval do
        after_update do |record|
          ChangesCallbacks.push_event :updated, record, options
        end
      end
    end

    def push_creations(klass, options)
      klass.class_eval do
        after_create do |record|
          ChangesCallbacks.push_event :created, record, options
        end
      end
    end

    def push_destroys(klass, options)
      klass.class_eval do
        after_destroy do |record|
          ChangesCallbacks.push_event :destroyed, record, options
        end
      end
    end

    def push_event(type, record, options)
      channels = channel_names_from(type, record, options)

      channels.each do |channel|
        event = Event.new(:event => type, :resource => record, :channel => channel)
        EventQueue.push event
      end
    end

    def channel_names_from(type, record, options)
      case options[:to]
      when String then
        [options[:to]]
      when Symbol then
        records = record.send options[:to]
        Channel.names_for(records)
      else
        [Channel.default_name_for(record)]
      end
    end
  end
end