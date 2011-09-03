require 'singleton'
require 'ffi'
require 'em-zeromq'

module Alondra
  class MessageQueue
    include Singleton

    def start_listening
      Rails.logger.info "Starting message queue"

      if @connection
        Rails.logger.warn 'Push connection to message queue started twice'
        reset!
      end

      @connection = context.bind(ZMQ::SUB, Alondra.config.queue_socket, self)
      @connection.setsockopt ZMQ::SUBSCRIBE, '' # receive all
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
        receive(Event.new(received_hash))
      elsif received_hash[:message]
        message = Message.new(received_hash[:message], received_hash[:channel_names])
        message.send_to_channels
      else
        Rails.logger.warn "Unrecognized message type #{received_string}"
      end
    end

    def receive(event)
      event_router.process(event)
    end

    def reset!
      @connection.close_connection()

      @connection  = nil
      @context     = nil
      @push_socket = nil
    end

    private

    def event_router
      @event_router ||= EventRouter.new
    end

    def context
      @context ||= EM::ZeroMQ::Context.new(1)
    end
  end
end

