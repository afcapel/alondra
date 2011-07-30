module PushyResources
  module MessageDispatcher
    extend self

    def parse(string)
      msg = ActiveSupport::JSON.decode(string).symbolize_keys
    end

    def dispatch(input, websocket)
      msg = parse(input)

      raise 'Unrecognized message' unless msg.kind_of?(Hash)

      if msg[:command]
        Command.new(websocket, msg).execute!
      elsif msg[:event]
        EventQueue.push(Event.new(msg))
      end
    end
  end
end