module PushyResources
  module MessageDispatcher
    extend self

    def parse(string)
      msg = ActiveSupport::JSON.decode(string)
      msg.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
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