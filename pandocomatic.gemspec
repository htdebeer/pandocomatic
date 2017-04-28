Gem::Specification.new do |s|
  s.name = 'pandocomatic'
  s.version = '0.1.3.3'
  s.license = 'GPL-3.0'
  s.date = '2017-03-04'
  s.summary = 'Automating the use of pandoc'
  s.description = 'Automating the use of pandoc <http://pandoc.org>: use pandocomatic to convert one file or a directory with files and sub directories.'
  s.author = ['Huub de Beer']
  s.email = 'Huub@heerdebeer.org'
  s.files = Dir['lib/pandocomatic/*.rb']
  s.files += Dir['lib/pandocomatic/default_configuration.yaml']
  s.files += Dir['lib/pandocomatic/command/*.rb']
  s.files += Dir['lib/pandocomatic/error/*.rb']
  s.files += Dir['lib/pandocomatic/printer/*.rb']
  s.files += Dir['lib/pandocomatic/printer/views/*.txt']
  s.add_runtime_dependency 'paru', '~> 0.2.4.1', '>= 0.2.4.1'
  s.add_runtime_dependency 'trollop', '~> 2.1.2', '>= 2.1.0'
  s.add_development_dependency 'minitest-reporters', '~> 0'
  s.add_development_dependency 'yard', '~> 0.9.8'
  s.executables << 'pandocomatic'
  s.homepage = 'https://heerdebeer.org/Software/markdown/pandocomatic/'
  s.requirements << 'pandoc, a universal document converer <http://pandoc.org>'
end
