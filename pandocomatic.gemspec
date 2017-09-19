Gem::Specification.new do |s|
  s.name = 'pandocomatic'
  s.version = '0.2'
  s.license = 'GPL-3.0'
  s.date = '2017-09-19'
  s.summary = 'Automating the use of pandoc'
  s.description = 'Pandocomatic is a tool to automate using pandoc (<http://pandoc.org>). With pandocomatic you can express common patterns of using pandoc for generating your documents. Applied to a directory, pandocomatic can act as a static site generator.'
  s.author = ['Huub de Beer']
  s.email = 'Huub@heerdebeer.org'
  s.files = Dir['lib/pandocomatic/*.rb']
  s.files += Dir['lib/pandocomatic/default_configuration.yaml']
  s.files += Dir['lib/pandocomatic/command/*.rb']
  s.files += Dir['lib/pandocomatic/error/*.rb']
  s.files += Dir['lib/pandocomatic/processors/*.rb']
  s.files += Dir['lib/pandocomatic/printer/*.rb']
  s.files += Dir['lib/pandocomatic/printer/views/*.txt']
  s.add_runtime_dependency 'paru', '~> 0.2.5', '>= 0.2.5.9'
  s.add_runtime_dependency 'trollop', '~> 2.1.2', '>= 2.1.0'
  s.add_development_dependency 'minitest-reporters', '~> 0'
  s.add_development_dependency 'yard', '~> 0.9.8'
  s.executables << 'pandocomatic'
  s.homepage = 'https://heerdebeer.org/Software/markdown/pandocomatic/'
  s.requirements << 'pandoc, a universal document converer <http://pandoc.org>'
end
