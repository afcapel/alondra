require_relative 'alondra/log'
require_relative 'alondra/message'
require_relative 'alondra/event'
require_relative 'alondra/connection'
require_relative 'alondra/channel'
require_relative 'alondra/command'
require_relative 'alondra/command_dispatcher'
require_relative 'alondra/event_router'
require_relative 'alondra/message_queue_client'
require_relative 'alondra/message_queue'
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
    
    initializer "configure EM thread pool" do
      # If we have more threads than db connections we will exhaust the conn pool
      threadpool_size = ActiveRecord::Base.connection_pool.instance_variable_get :@size
      threadpool_size -= 2 if threadpool_size > 2
      EM.threadpool_size = threadpool_size
    end

    initializer "enable sessions for flash websockets" do
      Rails.application.config.session_store :cookie_store, httponly: false
    end

    initializer "load listeners" do
      listeners_dir = File.join(Rails.root, 'app', 'listeners')
      
      Log.info "Loading event listeners in #{listeners_dir}"
      Dir[File.join(listeners_dir, '*.rb')].each { |file| require_dependency file }
    end
    
    config.after_initialize do
      PushController.send :include, Rails.application.routes.url_helpers
    end

    def self.start_server_in_new_thread!
      Thread.new do
        start_server!
      end
    end

    def self.start_server!
      start_server_proc = Proc.new do
        MessageQueue.instance.start_listening
        Server.run
      end
      
      if EM.reactor_running?
        EM.schedule(start_server_proc) 
      else
        Log.info "starting EM reactor"
        EM.run(start_server_proc)
      end
    end
  end
end




