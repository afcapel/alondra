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
        EventRouter.listeners << subclass
      end
    end

    def session
      @connection.session
    end

    def receive(event)
      @event        = event
      @resource     = event.resource
      @channel_name = event.channel_name
      @connection   = event.connection

      matching_callbacks = self.class.callbacks.find_all { |c| c.matches?(event) }
      matching_callbacks.each do |callback|
        begin
          self.instance_exec(event, &callback.proc)
        rescue Exception => ex
          Rails.logger.error 'Error while processing event listener callback'
          Rails.logger.error ex.message
          Rails.logger.error ex.stacktrace if ex.respond_to? :stacktrace
        end
      end
    end
  end
end