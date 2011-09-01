require_relative 'alondra/message'
require_relative 'alondra/event'
require_relative 'alondra/connection'
require_relative 'alondra/channel'
require_relative 'alondra/command'
require_relative 'alondra/event_router'
require_relative 'alondra/event_queue'
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

    def self.start!
      em_runner do
        Rails.logger.info "Starting alondra server... #{EM.reactor_running?}"
        EventQueue.instance.start
        Server.run
      end
    end

    def self.em_runner
      Rails.logger.debug "Proccess running EM: #{caller.last}"
      Rails.logger.debug "PROCESSS has pid #{Process.pid}"

      if EM.reactor_running?
        EM.schedule do
          yield
        end
      else
        Rails.logger.info "running EM reactor in new thread"
        Thread.new do
          EM.synchrony do
            yield
          end
          die_gracefully_on_signal
        end
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




