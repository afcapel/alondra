# Configure Rails Environment
ENV["RAILS_ENV"]    = "test"
ENV["ALONDRA_SERVER"] = 'true'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'capybara/rails'

Alondra::Alondra.start_server!

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
