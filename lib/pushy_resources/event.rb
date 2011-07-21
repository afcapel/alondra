module PushyResources
  class Event
    attr_reader :channel
    attr_reader :type
    attr_reader :resource

    def initialize(event_hash)
      @type     = event_hash[:event].to_sym
      @resource = event_hash[:resource]

      channel_name = event_hash[:channel] || get_channel_name
      @channel =  Channel[channel_name]
    end

    def to_json
      {:event => type,
       :resource_type => resource.class.name,
       :resource => resource.to_json,
       :channel => channel.name
      }.to_json
    end

    private

    def get_channel_name
      resource_name = @resource.class.name.pluralize.underscore

      if type == :updated
        "/#{resource_name}/#{resource.id}"
      else
        "/#{resource_name}/"
      end
    end
  end
end