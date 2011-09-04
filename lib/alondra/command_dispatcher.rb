module Alondra

  class NotRecognizedCommand < StandardError; end

  module CommandDispatcher
    extend self

    def dispatch(input, connection)
      msg = parse(input)

      unless msg.kind_of?(Hash) && msg[:command].present?
        raise NotRecognizedCommand.new("Unrecognized command: #{input}")
      end

      Command.new(connection, msg).execute!
    end

    def parse(string)
      msg = ActiveSupport::JSON.decode(string).symbolize_keys
    end
  end
end