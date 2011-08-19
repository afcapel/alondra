module PushyResources
  module Pushing
    def push(event_type, options = {})
      case event_type
      when :changes then
        PushCallbacks.push_updates(self, options)
        PushCallbacks.push_creations(self, options)
        PushCallbacks.push_destroys(self, options)
      when :updates   then
        PushCallbacks.push_updates(self, options)
      when :creations then
        PushCallbacks.push_creations(self, options)
      when :destroys  then
        PushCallbacks.push_destroys(self, options)
      end
    end
  end
end
