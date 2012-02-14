require 'em-websocket'

module Alondra
  module Server
    extend self

    def run
      Log.info "Server starting on port #{Alondra.config.port}"

      EM::WebSocket.start(:host => '0.0.0.0', :port => Alondra.config.port) do |websocket|

        websocket.onopen do
          session = SessionParser.parse(websocket)
          
          Log.info "client connected."
          Connection.new(websocket, session)
        end

        websocket.onclose do
          Log.info "Connection closed"
          Connections[websocket].destroy! if Connections[websocket].present?
        end

        websocket.onerror do |ex|
          puts "Error: #{ex.message}"
          Log.error "Error: #{ex.message}"
          Log.error ex.backtrace.join("\n")
          Connections[websocket].destroy! if Connections[websocket]
        end

        websocket.onmessage do |msg|
          Log.info "received: #{msg}"
          CommandDispatcher.dispatch(msg, Connections[websocket])
        end
      end

      EM.error_handler do |error|
        puts "Error raised during event loop: #{error.message}"
        Log.error "Error raised during event loop: #{error.message}"
        Log.error error.stacktrace if error.respond_to? :stacktrace
      end
    end
  end
end