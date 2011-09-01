module Alondra
  class Event
    attr_reader :channel_name
    attr_reader :type
    attr_reader :resource
    attr_reader :resource_type
    attr_reader :connection

    def initialize(event_hash, connection = nil)
      @connection = connection
      @type       = event_hash[:event].to_sym

      if Hash === event_hash[:resource]
        @resource = fetch_resource(event_hash[:resource_type], event_hash[:resource])
      else
        @resource = event_hash[:resource]
      end

      @resource_type = event_hash[:resource_type] || resource.class.name

      if event_hash[:channel].present?
        @channel_name  = event_hash[:channel]
      else
        channel_type = type == :updated ? :member : :collection
        Channel.default_name_for(resource, channel_type)
      end
    end

    def channel
      @channel ||= Channel[channel_name]
    end

    def fire!
      if connection
        EventQueue.instance.receive self
      else
        EventQueue.push self
      end
    end

    def as_json
      {
        :event         => type,
        :resource_type => resource_type,
        :resource      => resource.as_json,
        :channel       => channel_name
      }
    end

    def to_json
      ActiveSupport::JSON.encode(as_json)
    end

    private

    def fetch_resource(resource_type, attributes)
      attributes.symbolize_keys!
      resource_class = Kernel.const_get(resource_type)

      return attributes unless resource_class < ActiveRecord::Base

      if attributes[:id].present?
        resource_class.where(:id => attributes[:id]).first || build_resource(resource_class, attributes)
      else
        build_resource(resource_class, attributes)
      end
    end

    def build_resource(resource_class, attributes)
      reflections = resource_class.reflections
      resource_class.new.tap do |resource|
        attributes.each do |key, value|
          next unless resource.respond_to? "#{key}=".to_sym
          next if reflections[key] && reflections[key].klass != value.class

          resource.send("#{key}=", value)
        end
      end
    end
  end
end