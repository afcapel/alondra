module PushyResources
  module Pushing
    def push(options)
      raise 'You need to specify the channel to push' unless options[:to]

      channels = Channel.for(options.delete(:to))
      controller = PushController.new(self)
      controller.render_push(options, channels)
    end
  end
end