module Alondra

  class PushingException < StandardError; end

  module Pushing
    def push(options)
      raise PushingException.new('You need to specify the channel to push') unless options[:to]

      channels = Channel.for(options.delete(:to))
      controller = PushController.new(self)
      controller.render_push(options, channels)
    end
  end
end