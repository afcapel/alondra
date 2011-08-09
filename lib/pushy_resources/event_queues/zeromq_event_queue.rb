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
        event = Event.from_json(message.copy_out_string)
        EventRouter.process(event)
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