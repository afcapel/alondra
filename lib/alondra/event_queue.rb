module Alondra
  class EventQueue
    include Singleton

    def self.push(event)
      instance.send_message(event)
    end

    SOCKET_PATH = 'ipc:///tmp/alondra.ipc'

    def initialize
      Alondra.em_runner do
        start if ENV['ALONDRA_SERVER'].present?
      end
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
        receive(Event.new(received_hash))
      elsif received_hash[:message]
        message = Message.new(received_hash[:content])
      else
        Rails.logger.warn "Not recognized message type #{received_string}"
      end
    end

    def receive(event)
      event_router.process(event)
    end

    def send_message(message)
      EM.schedule do
        begin
          push_socket.send_msg(message.to_json)
        rescue Exception => ex
          Rails.logger.error "Exception while sending message to event quete: #{ex.message}"
        end
      end
    end

    def reset!
      @context     = nil
      @push_socket = nil
    end

    private

    def event_router
      @event_router ||= EventRouter.new
    end

    def push_socket
      @push_socket ||= context.connect(ZMQ::PUB, SOCKET_PATH)
    end

    def context
      @context ||= EM::ZeroMQ::Context.new(1)
    end
  end
end

