module Alondra
  class EventListener
    include Pushing

    attr_accessor :event
    attr_accessor :resource
    attr_accessor :channel_name

    class << self
      def listened_patterns
        @listened_patterns ||= [default_listened_pattern]
      end

      def listen_to?(channel_name)
        listened_patterns.any? { |p| p =~ channel_name }
      end

      def listen_to(channel_name)
        unless @custom_pattern_provided
          listened_patterns.clear
          @custom_pattern_provided = true
        end

        if Regexp === channel_name
          listened_patterns << channel_name
        else
          escaped_pattern = Regexp.escape(channel_name)
          listened_patterns << Regexp.new("^#{escaped_pattern}")
        end
      end

      def on(event_type, options = {}, &block)
        callbacks << ListenerCallback.new(event_type, options, block)
      end

      def callbacks
        @callbacks ||= []
      end

      def default_listened_pattern
        word = self.name.demodulize
        word.gsub!(/Listener$/, '')
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1\/\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1/\2')
        word.downcase!
        Regexp.new("^/#{word}")
      end

      def inherited(subclass)
        # In development mode Rails will load the same class many times
        # Delete it first if we already have parsed it
        EventRouter.listeners.delete_if { |l| l.name == subclass.name }
        EventRouter.listeners << subclass
      end

      def matching_callbacks_for(event)
        callbacks.find_all { |c| c.matches?(event) }
      end

      def process(event)
        matching_callbacks_for(event).each do |callback|
          new_instance = new(event)
          begin
            new_instance.instance_exec(event, &callback.proc)
          rescue Exception => ex
            Log.error 'Error while processing event listener callback'
            Log.error ex.message
            Log.error ex.backtrace.join("\n")
          end
        end
      end
    end

    def session
      @connection.session
    end

    def initialize(event)
      @event        = event
      @resource     = event.resource
      @channel_name = event.channel_name
      @connection   = event.connection
    end
  end
end