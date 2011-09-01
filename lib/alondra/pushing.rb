module Alondra

  class PushingException < StandardError; end

  module Pushing
    def push(*args)
      raise PushingException.new('You need to specify the channel to push') unless args.last[:to]

      channels = Channel.for(args.last.delete(:to))
      controller = PushController.new(self)
      controller.render_push(args, channels)
    end
  end
end