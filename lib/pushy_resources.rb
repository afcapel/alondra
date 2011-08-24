require 'singleton'

require_relative 'pushy_resources/message'
require_relative 'pushy_resources/event'
require_relative 'pushy_resources/connection'
require_relative 'pushy_resources/channel'
require_relative 'pushy_resources/command'
require_relative 'pushy_resources/event_router'
require_relative 'pushy_resources/event_queue'
require_relative 'pushy_resources/message_dispatcher'

require_relative 'pushy_resources/event_observer'
require_relative 'pushy_resources/credentials_parser'
require_relative 'pushy_resources/observer_callback'
require_relative 'pushy_resources/push_controller'
require_relative 'pushy_resources/pushing'
require_relative 'pushy_resources/changes_callbacks'
require_relative 'pushy_resources/changes_push'
require_relative 'pushy_resources/server'

module PushyResources
  class PushyResources < Rails::Engine

    # Setting default configuration values
    config.port  = 12345
    config.host  = 'localhost'

    initializer "sessions for flash websockets" do
      Rails.application.config.session_store :cookie_store, httponly: false
    end

    initializer "initializing pushy resources server" do
      Rails.logger.info "Extending active record"
      ActiveRecord::Base.extend ChangesPush
    end

    initializer "load observers" do
      Rails.logger.info "Loading event observers in #{File.join(Rails.root, 'app', 'observers', '*.rb')}"
      Dir[File.join(Rails.root, 'app', 'observers', '*.rb')].each { |file| require file }
    end

    initializer "start event loop" do

      if EM.reactor_running?
        Rails.logger.info "Initializing server"
        Server.run if ENV['PUSHY_SERVER']
      else
        Thread.new do
          Rails.logger.info "Running EM reactor in new thread"
          EM.synchrony do
            Server.run if ENV['PUSHY_SERVER']
          end
        end
      end
    end
  end
end




