Dir[File.dirname(__FILE__) + '/pushy_resources/*.rb'].each {|file| require file }

class ActiveRecord::Base
  extend PushyResources::Pushing
end

if EM.reactor_running?
  PushyResources::Server.run
else
  Thread.new do
    puts "Running EM reactor in new thread"
    EM.run { PushyResources::Server.run }
  end
end

EM.error_handler do |error|
  puts "Error raised during event loop: #{error.message}"
  puts error.stacktrace
end


