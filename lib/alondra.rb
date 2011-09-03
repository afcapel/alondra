require_relative 'alondra/message'
require_relative 'alondra/event'
require_relative 'alondra/connection'
require_relative 'alondra/channel'
require_relative 'alondra/command'
require_relative 'alondra/event_router'
require_relative 'alondra/message_queue_client'
require_relative 'alondra/message_queue'
require_relative 'alondra/message_dispatcher'
require_relative 'alondra/pushing'
require_relative 'alondra/event_listener'
require_relative 'alondra/session_parser'
require_relative 'alondra/listener_callback'
require_relative 'alondra/push_controller'
require_relative 'alondra/changes_callbacks'
require_relative 'alondra/changes_push'
require_relative 'alondra/server'

module Alondra

  ActiveRecord::Base.extend ChangesPush
  ActionController::Base.send :include, Pushing

  class Alondra < Rails::Engine

    # Setting default configuration values
    config.port         = Rails.env == 'test' ? 12346 : 12345
    config.host         = 'localhost'
    config.queue_socket = 'ipc:///tmp/alondra.ipc'

    initializer "enable sessions for flash websockets" do
      Rails.application.config.session_store :cookie_store, httponly: false
    end

    initializer "load listeners" do
      Rails.logger.info "Loading event listeners in #{File.join(Rails.root, 'app', 'listeners', '*.rb')}"
      Dir[File.join(Rails.root, 'app', 'listeners', '*.rb')].each { |file| require file }
    end

    def self.start_server_in_new_thread!
      Thread.new do
        start_server!
      end
    end

    def self.start_server!
      if EM.reactor_running?
        EM.schedule do
          MessageQueue.instance.start_listening
          Server.run
        end
      else
        Rails.logger.info "starting EM reactor"
        EM.run do
          MessageQueue.instance.start_listening
          Server.run
        end
        die_gracefully_on_signal
      end
    end

    def self.die_gracefully_on_signal
      Signal.trap("INT")  do
        Rails.logger.warn "INT signal trapped. Shutting down EM reactor"
        EM.stop
      end

      Signal.trap("TERM") do
        Rails.logger.warn "TERM signal trapped. Shutting down EM reactor"
        EM.stop
      end
    end
  end
end




