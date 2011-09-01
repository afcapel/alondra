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
      message_string = render_to_string(*options)
      msg = Message.new(message_string)
      msg.send_to channels
    end

    def _prefixes
      ['application']
    end

    def view_paths
      @view_paths ||= begin
        paths = ApplicationController.send '_view_paths'
        paths
      end
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