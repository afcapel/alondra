module Alondra

  class PushingException < StandardError; end

  module Pushing
    def push(*args)
      raise PushingException.new('You need to specify the channel to push') unless args.last[:to].present?

      to = args.last.delete(:to)
      
      # If we are called in the context of a request we save this information
      # so we can create proper routes
      caller_request = self.respond_to?(:request) ? request : nil
      
      controller = PushController.new(self, to, caller_request)
      controller.render_push(args)
    end
  end
end