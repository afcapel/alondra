module PushyResources
  class Message
    attr_reader :content

    def self.from_json(message_hash)
      message_hash = ActiveSupport::JSON.decode(s).symbolize_keys
      self.new(message_hash[:content])
    end

    def initialize(content)
      @content = content
    end

    def enqueue
      EventQueue.push self
    end

    def send_to(channels)
      channels.each do |channel|
        channel.receive self
      end
    end

    def to_json
      ActiveSupport::JSON.encode :message => content
    end
  end
end