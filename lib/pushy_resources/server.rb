require 'em-websocket'
require 'em-synchrony'
require 'em-synchrony/em-http'

module PushyResources
  module Server
    extend self

    def run
      EM.synchrony do
        puts "Server started on 0.0.0.0:12345"

        EM::WebSocket.start(:host => '0.0.0.0', :port => 12345) do |websocket|

          websocket.onopen { puts "Client connected" }

          websocket.onclose { puts "closed" }

          websocket.onerror do |ex|
            puts "Error: #{ex.message}"
            puts ex.backtrace
          end

          websocket.onmessage do |msg|
            puts "received: #{msg}"
            MessageDispatcher.dispatch(msg, websocket)
          end
        end
      end
    end
  end
end