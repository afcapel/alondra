module Alondra
  class Message
    attr_reader :content
    attr_reader :channel_names

    def initialize(content, channel_names)
      @content       = content
      @channel_names = channel_names
    end

    def enqueue
      MessageQueueClient.push self
    end

    def send_to_channels
      channels.each do |channel|
        channel.receive self
      end
    end

    def as_json
      {:message => content, :channel_names => channel_names}
    end

    def to_json
      ActiveSupport::JSON.encode(as_json)
    end

    private

    def channels
      channel_names.collect { |name| Channel[name] }
    end
  end
end