# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "alondra"
  s.summary = "Add real time capabilities to your rails app"
  s.description = "Add real time capabilities to your rails app"
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.version = "0.0.1"
  s.authors = ['Alberto F. Capel']

  # Dependencies
  s.add_dependency('daemons')
  s.add_dependency('uuidtools')
  s.add_dependency('rails', '>= 3.1.0')
  s.add_dependency('eventmachine', '>= 1.0.0.beta.3')
  s.add_dependency('em-websocket')
  s.add_dependency('em-synchrony')
  s.add_dependency('em-http-request')
  s.add_dependency('ffi', '1.0.9')
  s.add_dependency('em-zeromq', '0.2.1')
end
