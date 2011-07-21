module PushyResources

  module ConfigMethods
    def config(*args, &block)
      if block_given?
        Configuration.instance.instance_eval(&block)
      else
        Configuration.instance.send(args.first)
      end
    end
  end

  extend ConfigMethods


  class Configuration
    include Singleton

    def options
      @options ||= {
        :event_queue         => :redis,
        :redis_event_channel => 'PushyEvents',
        :redis_server        => 'localhost',
        :redis_port          =>  6379
      }
    end

    def method_missing(name, *args)
      if args.empty?
        options[name]
      else
        options[name] = args.first
      end
    end
  end
end