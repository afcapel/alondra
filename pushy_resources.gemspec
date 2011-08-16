# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "pushy_resources"
  s.summary = "Push model updates to the client"
  s.description = "Push model updates to the client"
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.version = "0.0.1"
  s.authors = ['Alberto F. Capel']

  # Dependencies
  s.add_dependency('eventmachine', '>= 1.0.0.beta.4')
  s.add_dependency('em-websocket')
  s.add_dependency('em-synchrony')
  s.add_dependency('em-http-request')
end
