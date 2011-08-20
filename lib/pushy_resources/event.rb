module PushyResources
  class Event
    attr_reader :channel_name
    attr_reader :type
    attr_reader :resource
    attr_reader :resource_type

    def self.from_json(s)
      event_hash = ActiveSupport::JSON.decode(s).symbolize_keys

      event_hash[:resource] = fetch_resource(event_hash[:resource_type], event_hash[:resource])
      Event.new(event_hash)
    end


    def self.fetch_resource(resource_type, attributes)
      attributes.symbolize_keys!
      resource_class = Kernel.const_get(resource_type)

      return attributes unless resource_class < ActiveRecord::Base

      if attributes[:id].present?
        resource_class.where(:id => attributes[:id]).first || build_resource(resource_class, attributes)
      else
        build_resource(resource_class, attributes)
      end
    end

    def self.build_resource(resource_class, attributes)
      reflections = resource_class.reflections
      resource_class.new.tap do |resource|
        attributes.each do |key, value|
          next unless resource.respond_to? "#{key}=".to_sym
          next if reflections[key] && reflections[key].klass != value.class

          resource.send("#{key}=", value)
        end
      end
    end

    def initialize(event_hash)
      @type          = event_hash[:event].to_sym
      @resource      = event_hash[:resource]
      @resource_type = event_hash[:resource_type] || resource.class.name
      @channel_name  = event_hash[:channel] || Channel.default_name_for(type, resource)
    end

    def channel
      @channel ||= Channel[channel_name]
    end

    def fire!
      EventQueue.push self
    end

    def to_json
      ActiveSupport::JSON.encode({
        :event         => type,
        :resource_type => resource_type,
        :resource      => resource.as_json,
        :channel       => channel_name
        })
    end
  end
end