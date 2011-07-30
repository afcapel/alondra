module PushyResources
  class Event
    attr_reader :channel_name
    attr_reader :type
    attr_reader :resource
    attr_reader :resource_type

    def self.from_json(s)
      event_hash = ActiveSupport::JSON.decode(s).symbolize_keys
      event_hash = event_hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

      event_hash[:resource] = fetch_resource(event_hash[:resource_type], event_hash[:resource])
      Event.new(event_hash)
    end


    def self.fetch_resource(resource_type, attributes)
      resource_class = Kernel.const_get(resource_type)

      if resource_class == NilClass
        attributes
      else
        resource = resource_class.new
        attributes.each do |key, value|
          resource.send("#{key}=", value)
        end
        resource
      end
    end

    def initialize(event_hash)
      @type          = event_hash[:event].to_sym
      @resource      = event_hash[:resource]
      @resource_type = event_hash[:resource_type] || resource.class.name
      @channel_name  = event_hash[:channel] || default_channel_name
    end

    def channel
      @channel ||= Channel[channel_name]
    end

    def to_json
      ActiveSupport::JSON.encode({
        :event         => type,
        :resource_type => resource_type,
        :resource      => resource.as_json,
        :channel       => channel_name
      })
    end

    private

    def default_channel_name
      resource_name = @resource.class.name.pluralize.underscore

      if type == :updated
        "/#{resource_name}/#{resource.id}"
      else
        "/#{resource_name}/"
      end
    end
  end
end