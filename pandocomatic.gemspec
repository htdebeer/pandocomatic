require_relative 'lib/pandocomatic/version'

Gem::Specification.new do |s|
  s.name = 'pandocomatic'
  s.version = Pandocomatic::VERSION.join '.'
  s.license = 'GPL-3.0'
  s.summary = 'Automate the use of pandoc'
  s.description = 'Pandocomatic is a tool to automate using pandoc. With pandocomatic you can express common patterns of using pandoc for generating your documents. Applied to a directory, pandocomatic can act as a static site generator.'
  s.author = ['Huub de Beer']
  s.email = 'Huub@heerdebeer.org'
  s.required_ruby_version = '>= 2.6.8'
  s.files = Dir['lib/pandocomatic/*.rb']
  s.files += Dir['lib/pandocomatic/default_configuration.yaml']
  s.files += Dir['lib/pandocomatic/command/*.rb']
  s.files += Dir['lib/pandocomatic/error/*.rb']
  s.files += Dir['lib/pandocomatic/processors/*.rb']
  s.files += Dir['lib/pandocomatic/printer/*.rb']
  s.files += Dir['lib/pandocomatic/printer/views/*.txt']
  s.add_runtime_dependency 'optimist', '~> 3.0.0', '>= 3.0.0'
  s.add_runtime_dependency 'paru', '~> 1.1', '>= 1.2.1'
  s.add_development_dependency 'minitest', '~> 5.15'
  s.add_development_dependency 'minitest-reporters', '~> 1.5'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rubocop', '~> 1.56.4'
  s.add_development_dependency 'yard', '~> 0.9.27'
  s.executables << 'pandocomatic'
  s.homepage = 'https://heerdebeer.org/Software/markdown/pandocomatic/'
  s.requirements << 'pandoc, a universal document converter'
  s.metadata['rubygems_mfa_required'] = 'true'
end
