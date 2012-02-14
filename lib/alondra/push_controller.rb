module Alondra
  class PushController
    include ActiveSupport::Configurable
    include AbstractController::Logger
    include AbstractController::Rendering
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths
    include ActionController::RequestForgeryProtection

    attr_accessor :channel_names
    attr_accessor :request

    def initialize(context, to, request = nil)
      @channel_names = Channel.names_for(to)
      @request = request
      
      self.class.view_paths = ActionController::Base.view_paths
      copy_instance_variables_from(context)
    end

    def render_push(options)
      if EM.reactor_thread?
        Log.warn('You are rendering a view from the Event Machine reactor thread')
        Log.warn('Rendering a view is a possibly blocking operation, so be careful')
      end

      message_content = render_to_string(*options)
      msg = Message.new(message_content, channel_names)
      msg.enqueue
    end

    def _prefixes
      ['application']
    end

    def view_paths
      @view_paths ||= ApplicationController.send '_view_paths'
    end
    
    def action_name
      'push'
    end

    private

    def copy_instance_variables_from(context)
      context.instance_variables.each do |var|
        value = context.instance_variable_get(var)
        instance_variable_set(var, value)
      end
    end
  end
end