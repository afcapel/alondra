require 'singleton'
require 'ffi-rzmq'
require 'em-zeromq'

module Alondra
  class MessageQueueClient

    def self.push(message)
      instance.send_message(message)
    end

    def self.instance
      if EM.reactor_running?
        async_instance
      else
        sync_instance
      end
    end

    def self.async_instance
      @async_instance ||= AsyncMessageQueueClient.new
    end

    def self.sync_instance
      @sync_instance ||= SyncMessageQueueClient.new
    end
  end

  class AsyncMessageQueueClient < MessageQueueClient
    def send_message(message)
      EM.schedule do
        begin
          push_socket.send_msg(message.to_json)
        rescue Exception => ex
          Log.error "Exception while sending message to message queue: #{ex.message}"
        end
      end
    end

    def push_socket
      @push_socket ||= begin
        push_socket = context.socket(ZMQ::PUSH)
        push_socket.connect(Alondra.config.queue_socket)
        push_socket
      end
    end

    def context
      @context ||= EM::ZeroMQ::Context.new(1)
    end
  end

  class SyncMessageQueueClient < MessageQueueClient

    def send_message(message)
      begin
        push_socket.send_string(message.to_json)
      rescue Exception => ex
        Log.error "Exception while sending message to message queue: #{ex.message}"
      end
    end

    def push_socket
      @push_socket ||= begin
        socket = context.socket(ZMQ::PUSH)
        socket.connect(Alondra.config.queue_socket)
        socket
      end
    end

    def context
      @context ||= ZMQ::Context.new(1)
    end
  end
end