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
      messages.each do |message|
        begin
          event = Event.from_json(message.copy_out_string)
          EventRouter.process(event)
        rescue Exception => ex
          Rails.logger.error "Error raised while processing message"
          Rails.logger.error "#{ex.class}: #{ex.message}"
          Rails.logger.error ex.backtrace.join("\n") if ex.respond_to? :backtrace
        end
      end
    end

    def send(event)
      EM.schedule do
        push_socket.send_msg(event.to_json)
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

