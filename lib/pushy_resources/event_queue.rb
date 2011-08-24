module PushyResources
  class EventQueue
    include Singleton

    def self.start
      self.instance
    end

    def self.push(event)
      instance.send(event)
    end

    SOCKET_PATH = 'ipc:///tmp/pushy_resources'

    attr_reader :received

    def initialize
      Rails.logger.debug "Starting event queue"

      if ENV['PUSHY_SERVER'].present?
        conn = context.bind(ZMQ::SUB, SOCKET_PATH, self)
        conn.setsockopt ZMQ::SUBSCRIBE, '' # receive all
      end
    end

    def on_readable(socket, messages)
      messages.each do |received|
        begin
          parse received.copy_out_string
        rescue Exception => ex
          Rails.logger.error "Error raised while processing message"
          Rails.logger.error "#{ex.class}: #{ex.message}"
          Rails.logger.error ex.backtrace.join("\n") if ex.respond_to? :backtrace
        end
      end
    end

    def parse(received_string)
      received_hash = ActiveSupport::JSON.decode(received_string).symbolize_keys
      if received_hash[:event]
        event = Event.new(received_hash)
        EventRouter.process(event)
      elsif received_hash[:message]
        message = Message.new(received_hash[:content])
      else
        Rails.logger.error "Not recognized message type #{received.copy_out_string}"
      end
    end

    def send(message)
      EM.schedule do
        push_socket.send_msg(message.to_json)
      end
    end

    private

    def push_socket
      @push_socket ||= context.connect(ZMQ::PUB, SOCKET_PATH)
    end

    def context
      @context ||= EM::ZeroMQ::Context.new(1)
    end
  end
end

