module Alondra
  module Log
    extend self
    
    NUMBER_TO_NAME_MAP  = {0=>'DEBUG', 1=>'INFO', 2=>'WARN', 3=>'ERROR', 4=>'FATAL', 5=>'UNKNOWN'}
    NUMBER_TO_COLOR_MAP = {0=>'0;37', 1=>'32', 2=>'33', 3=>'31', 4=>'31', 5=>'37'}
   
    
    def debug(message)
      add(ActiveSupport::BufferedLogger::Severity::DEBUG, message)
    end
    
    def info(message)
      add(ActiveSupport::BufferedLogger::Severity::INFO, message)
    end
    
    def warn(message)
      add(ActiveSupport::BufferedLogger::Severity::WARN, message)
    end
    
    def error(message)
      add(ActiveSupport::BufferedLogger::Severity::ERROR, message)
    end
    
    def fatal(message)
      add(ActiveSupport::BufferedLogger::Severity::FATAL, message)
    end
    
    def unkwon(message)
      add(ActiveSupport::BufferedLogger::Severity::UNKNOWN, message)
    end
    
    private
    
    def add(severity, message = nil, progname = 'ALONDRA')
      sevstring = NUMBER_TO_NAME_MAP[severity]
      color     = NUMBER_TO_COLOR_MAP[severity]
      
      message = "\n\033[35m#{progname}:\033[0m[\033[#{color}m#{sevstring}\033[0m] #{message.strip}\033\n"
      Rails.logger.add(severity, message, progname)
    end
  end
end