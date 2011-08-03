module PushyResources
  class EventObserver

    class << self
      def observed_patterns
        @observed_patterns ||= [default_observed_pattern]
      end

      def observe?(channel_name)
        observed_patterns.any? { |p| p =~ channel_name }
      end

      def observe(channel_name)
        unless @custom_pattern_provided
          observed_patterns.clear
          @custom_pattern_provided = true
        end

        if Regexp === channel_name
          observed_patterns << channel_name
        else
          escaped_pattern = Regexp.escape(channel_name)
          observed_patterns << Regexp.new("^#{escaped_pattern}")
        end
      end

      def on(event_type, &block)
        self.callbacks_for(event_type) << block
      end

      def callbacks
        @callbacks ||= {}
      end

      def callbacks_for(event_type)
        callbacks[event_type] ||= []
      end

      def default_observed_pattern
        word = self.name.demodulize
        word.gsub!(/Observer$/, '')
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1\/\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1/\2')
        word.downcase!
        Regexp.new("^/#{word}")
      end

      def inherited(subclass)
        EventRouter.instance.observers << subclass
      end
    end


    def receive(event)
      self.class.callbacks_for(event.type).each do |block|
        self.instance_exec(event, &block)
      end
    end
  end
end