# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "alondra"
  s.summary = "Add real time capabilities to your rails app"
  s.description = "Add real time capabilities to your rails app"
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.version = "0.0.1"
  s.authors = ['Alberto F. Capel']

  # Dependencies
  s.add_dependency('daemons')
  s.add_dependency('eventmachine', '>= 1.0.0.beta.4')
  s.add_dependency('em-websocket')
  s.add_dependency('em-synchrony')
  s.add_dependency('em-http-request')
  s.add_dependency('uuidtools')
  s.add_dependency('em-zeromq')
end
