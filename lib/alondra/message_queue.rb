require 'singleton'
require 'ffi'
require 'em-zeromq'

module Alondra
  class MessageQueue
    include Singleton

    def start_listening
      Log.info "Starting message queue"

      if @pull_socket || @push_socket
        Log.warn 'Connections to message queue started twice'
        reset!
      end
      
      push_socket  
      pull_socket
      
      self
    end

    def on_readable(socket, messages)
      messages.each do |received|
        begin
          parse received.copy_out_string
        rescue Exception => ex
          Log.error "Error raised while processing message"
          Log.error "#{ex.class}: #{ex.message}"
          Log.error ex.backtrace.join("\n") if ex.respond_to? :backtrace
        end
      end
    end

    def parse(received_string)
      received_hash = ActiveSupport::JSON.decode(received_string).symbolize_keys

      if received_hash[:event]
        event = Event.new(received_hash, received_string)
        receive(event)
      elsif received_hash[:message]
        message = Message.new(received_hash[:message], received_hash[:channel_names])
        message.send_to_channels
      else
        Log.warn "Unrecognized message type #{received_string}"
      end
    end

    def receive(event)
      event_router.process(event)
    end
    
    def push_socket
      @push_socket ||= begin
        push_socket = context.socket(ZMQ::PUSH)  
        push_socket.connect(Alondra.config.queue_socket)
        push_socket
      end
    end
    
    def pull_socket
      @pull_socket ||= begin
        pull_socket = context.socket(ZMQ::PULL, self)  
        pull_socket.bind(Alondra.config.queue_socket)
        pull_socket
      end
    end

    def reset!
      @push_socket.close()
      @pull_socket.close()
      
      @context     = nil
      @push_socket = nil
      @pull_socket = nil
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

