module Alondra
  class EventQueue
    include Singleton

    def self.push(event)
      instance.send(event)
    end

    SOCKET_PATH = 'ipc:///tmp/alondra'

    attr_reader :received

    def initialize
      start if ENV['ALONDRA_SERVER'].present?
    end

    def start
      Rails.logger.info "Starting event queue"
      conn = context.bind(ZMQ::SUB, SOCKET_PATH, self)
      conn.setsockopt ZMQ::SUBSCRIBE, '' # receive all
    end

    def on_readable(socket, messages)
      messages.each do |received|
        begin
          Rails.logger.debug "received in queue #{received.copy_out_string}"
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
        Rails.logger.warn "Not recognized message type #{received_string}"
      end
    end

    def send(message)
      EM.next_tick do
        push_socket.send_msg(message.to_json)
      end
    end

    def reset!
      @context     = nil
      @push_socket = nil
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
