require 'em-websocket'
require 'em-synchrony'
require 'em-synchrony/em-http'

module Alondra
  module Server
    extend self

    def run
      EventQueue.instance.start

      puts "Server starting on port #{Alondra.config.port}"
      Rails.logger.error "Server starting on port #{Alondra.config.port}"

      EM::WebSocket.start(:host => '0.0.0.0', :port => Alondra.config.port) do |websocket|

        websocket.onopen do
          session = SessionParser.parse(websocket)

          Rails.logger.info "client connected."
          Connection.new(websocket, session)
        end

        websocket.onclose do
          Rails.logger.info "Connection closed"
          Connections[websocket].destroy! if Connections[websocket].present?
        end

        websocket.onerror do |ex|
          Rails.logger.error "Error: #{ex.message}"
          Rails.logger.error ex.backtrace.join("\n")
          Connections[websocket].destroy! if Connections[websocket]
        end

        websocket.onmessage do |msg|
          Rails.logger.info "received: #{msg}"
          MessageDispatcher.dispatch(msg, Connections[websocket])
        end
      end

      EM.error_handler do |error|
        Rails.logger.error "Error raised during event loop: #{error.message}"
        Rails.logger.error error.stacktrace if error.respond_to? :stacktrace
      end
    end
  end
end