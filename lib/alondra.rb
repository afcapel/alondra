require 'singleton'

require_relative 'alondra/message'
require_relative 'alondra/event'
require_relative 'alondra/connection'
require_relative 'alondra/channel'
require_relative 'alondra/command'
require_relative 'alondra/event_router'
require_relative 'alondra/event_queue'
require_relative 'alondra/message_dispatcher'
require_relative 'alondra/pushing'
require_relative 'alondra/event_observer'
require_relative 'alondra/credentials_parser'
require_relative 'alondra/observer_callback'
require_relative 'alondra/push_controller'
require_relative 'alondra/changes_callbacks'
require_relative 'alondra/changes_push'
require_relative 'alondra/server'

module Alondra
  class Alondra < Rails::Engine

    # Setting default configuration values
    config.port  = 12345
    config.host  = 'localhost'

    initializer "sessions for flash websockets" do
      Rails.application.config.session_store :cookie_store, httponly: false
    end

    initializer "extending active record" do
      Rails.logger.info "Extending active record"
      ActiveRecord::Base.extend ChangesPush
    end

    initializer "load observers" do
      Rails.logger.info "Loading event observers in #{File.join(Rails.root, 'app', 'observers', '*.rb')}"
      Dir[File.join(Rails.root, 'app', 'observers', '*.rb')].each { |file| require file }
    end

    def self.start!
      em_runner do
        Rails.logger.info "Starting alondra server... #{EM.reactor_running?}"
        Server.run
      end
    end

    def self.em_runner
      Rails.logger.info "Proccess running EM: #{caller.last}"
      Rails.logger.info "PROCESSS has pid #{Process.pid}"

      if EM.reactor_running?
        EM.schedule do
          yield
        end
      else
        Rails.logger.info "running event queue in new thread"
        Thread.new do
          EM.synchrony do
            yield
          end
          die_gracefully_on_signal
        end
      end
    end

    def self.die_gracefully_on_signal
      Signal.trap("INT")  { EM.stop }
      Signal.trap("TERM") { EM.stop }
    end
  end
end




