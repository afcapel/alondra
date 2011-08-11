module PushyResources
  class ZeromqEventQueue < EventQueue

    SOCKET_PATH = 'ipc:///tmp/pushy_resources'

    attr_reader :received

    def initialize
      EM.next_tick do
        context.connect(ZMQ::PULL, SOCKET_PATH, self)
      end
    end

    def on_readable(socket, messages)
      messages.each do |message|
        begin
          event = Event.from_json(message.copy_out_string)
          EventRouter.process(event)
        rescue Exception => ex
          puts "Error raised while processing message"
          puts "#{ex.class}: #{ex.message}"
          puts ex.backtrace.join("\n") if ex.respond_to? :backtrace
        end
      end
    end

    def send(event)
      EM.next_tick do
        push_socket.send_msg(event.to_json)
      end
    end

    private

    def push_socket
      @push_socket ||= context.bind(ZMQ::PUSH, SOCKET_PATH)
    end

    def context
      @context ||= EM::ZeroMQ::Context.new(1)
    end
  end
end