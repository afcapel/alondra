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
        @resource = fetch(event_hash[:resource_type], event_hash[:resource])
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
      @json_encoded ||= ActiveSupport::JSON.encode(as_json)
    end

    private

    def fetch(resource_type_name, attributes)
      attributes.symbolize_keys!
      resource_class = Kernel.const_get(resource_type_name)

      return attributes unless resource_class < ActiveRecord::Base

      resource = resource_class.new

      filtered_attributes = attributes.delete_if { |k,v| !resource.has_attribute?(k) }

      resource.assign_attributes(filtered_attributes, :without_protection => true)
      resource
    end

  end
end