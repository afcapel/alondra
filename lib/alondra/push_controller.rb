module Alondra
  class PushController
    include ActiveSupport::Configurable
    include AbstractController::Logger
    include AbstractController::Rendering
    include AbstractController::Helpers
    include AbstractController::Translation
    include AbstractController::AssetPaths
    include AbstractController::ViewPaths

    def initialize(context)
      self.class.view_paths = ActionController::Base.view_paths
      copy_instance_variables_from(context)
    end

    def render_push(options, channels)

      if EM.reactor_thread?
        render_async(options, channels)
      else
        render_sync(options, channels)
      end
    end

    def render_async(options, channels)
      # View rendering could trigger I/O blocking operations
      # so defer it to another thread
      render_op = Proc.new do
        render_to_string(*options)
      end

      callback = Proc.new do |message_content|
        msg = Message.new(message_content)
        msg.send_to channels
      end

      EM.defer(render_op, callback)
    end

    def render_sync(options, channels)
      message_content = render_to_string(*options)
      msg = Message.new(message_content)
      msg.send_to channels
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