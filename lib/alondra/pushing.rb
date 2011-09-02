module Alondra

  class PushingException < StandardError; end

  module Pushing
    def push(*args)
      raise PushingException.new('You need to specify the channel to push') unless args.last[:to].present?

      to = args.last.delete(:to)
      controller = PushController.new(self, to)
      controller.render_push(args)
    end
  end
end