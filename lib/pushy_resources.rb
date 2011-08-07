require 'singleton'
Dir[File.dirname(__FILE__) + '/pushy_resources/*.rb'].each {|file| require file }

module PushyResources
   class PushyResources < Rails::Engine

     # Setting default configuration values
     config.event_queue         = :memory
     config.redis_event_channel = 'PushyEvents'
     config.redis_server        = 'localhost'
     config.redis_port          = 6379

     initializer "sessions for flash websockets" do
       Rails.application.config.session_store :cookie_store, httponly: false
     end

     initializer "initializing pushy resources server" do
       Rails.logger.info "Extending active record"

        ActiveRecord::Base.extend Pushing

        Rails.logger.info "Loading event observers in #{File.join(Rails.root, 'app', 'observers', '*.rb')}"
        Dir[File.join(Rails.root, 'app', 'observers', '*.rb')].each {|file| Rails.logger.info "requiring #{file}"; require file }

        if EM.reactor_running?
          Rails.logger.info "Initializing server"
          PushyResources::Server.run
        else
          Thread.new do
            Rails.logger.info "Running EM reactor in new thread"
            EM.run { Server.run }
          end
        end

        EM.error_handler do |error|
          Rails.logger.error "Error raised during event loop: #{error.message}"
          Rails.logger.error error.stacktrace
        end
     end
   end
end




