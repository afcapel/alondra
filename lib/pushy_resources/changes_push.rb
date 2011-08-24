module PushyResources
  module ChangesPush
    def push(event_type, options = {})
      case event_type
      when :changes then
        ChangesCallbacks.push_updates(self, options)
        ChangesCallbacks.push_creations(self, options)
        ChangesCallbacks.push_destroys(self, options)
      when :updates then
        ChangesCallbacks.push_updates(self, options)
      when :creations then
        ChangesCallbacks.push_creations(self, options)
      when :destroys  then
        ChangesCallbacks.push_destroys(self, options)
      end
    end
  end
end
