require_relative 'lib/pandocomatic/version'

Gem::Specification.new do |s|
  s.name = 'pandocomatic'
  s.version = Pandocomatic::VERSION.join '.'
  s.license = 'GPL-3.0-or-later'
  s.summary = 'Automate the use of pandoc'
  s.description = 'Pandocomatic is a tool to automate using pandoc. With pandocomatic'
  s.description += ' you can express common patterns of using pandoc for generating'
  s.description += ' your documents. Applied to a directory, pandocomatic can act as a'
  s.description += ' static site generator.'
  s.author = ['Huub de Beer']
  s.email = 'Huub@heerdebeer.org'
  s.required_ruby_version = '>= 3.1.0'
  s.files = Dir['lib/pandocomatic/*.rb']
  s.files += Dir['lib/pandocomatic/default_configuration.yaml']
  s.files += Dir['lib/pandocomatic/command/*.rb']
  s.files += Dir['lib/pandocomatic/error/*.rb']
  s.files += Dir['lib/pandocomatic/processors/*.rb']
  s.files += Dir['lib/pandocomatic/printer/*.rb']
  s.files += Dir['lib/pandocomatic/printer/views/*.txt']
  s.add_dependency 'logger', '~> 1.7'
  s.add_dependency 'optimist', '~> 3.2', '>= 3.2'
  s.add_dependency 'paru', '~> 1.1', '>= 1.5.2'
  s.executables << 'pandocomatic'
  s.homepage = 'https://heerdebeer.org/Software/markdown/pandocomatic/'
  s.requirements << 'pandoc, a universal document converter'
  s.metadata['rubygems_mfa_required'] = 'true'
end
