Gem::Specification.new do |s|
  s.name = 'pandocomatic'
  s.version = '0.2.5.4'
  s.license = 'GPL-3.0'
  s.date = '2019-07-18'
  s.summary = 'Automate the use of pandoc'
  s.description = 'Pandocomatic is a tool to automate using pandoc. With pandocomatic you can express common patterns of using pandoc for generating your documents. Applied to a directory, pandocomatic can act as a static site generator.'
  s.author = ['Huub de Beer']
  s.email = 'Huub@heerdebeer.org'
  s.required_ruby_version = ">= 2.4.4"
  s.files = Dir['lib/pandocomatic/*.rb']
  s.files += Dir['lib/pandocomatic/default_configuration.yaml']
  s.files += Dir['lib/pandocomatic/command/*.rb']
  s.files += Dir['lib/pandocomatic/error/*.rb']
  s.files += Dir['lib/pandocomatic/processors/*.rb']
  s.files += Dir['lib/pandocomatic/printer/*.rb']
  s.files += Dir['lib/pandocomatic/printer/views/*.txt']
  s.add_runtime_dependency 'paru', '~> 0.3.2', '>= 0.3.2.0'
  s.add_runtime_dependency 'optimist', '~> 3.0.0', '>= 3.0.0'
  s.add_development_dependency 'minitest-reporters', '~> 1.3'
  s.add_development_dependency 'yard', '~> 0.9.18'
  s.executables << 'pandocomatic'
  s.homepage = 'https://heerdebeer.org/Software/markdown/pandocomatic/'
  s.requirements << 'pandoc, a universal document converter'
end
