Gem::Specification.new do |s|
  s.name = "pandocomatic"
  s.version = "0.1.0"
  s.license = "GPL-3.0"
  s.date = "2016-11-19"
  s.summary = "Automating the use of pandoc"
  s.description = "Automating the use of pandoc <http://pandoc.org>: use pandocomatic to convert one file or a directory tree of files."
  s.author = ["Huub de Beer"]
  s.email = "Huub@heerdebeer.org"
  s.files = ["lib/pandocomatic/configuration.rb", 
             "lib/pandocomatic/default_configuration.yaml",
             "lib/pandocomatic/dir_converter.rb", 
             "lib/pandocomatic/file_converter.rb", 
             "lib/pandocomatic/pandoc_metadata.rb",
             "lib/pandocomatic/processor.rb",
             "lib/pandocomatic/fileinfo_preprocessor.rb"
            ]
  s.add_runtime_dependency "paru", "~> 0.2", ">= 0.2.0"
  s.add_runtime_dependency "trollop", "~> 2.1.2", ">= 2.1.0"
  s.add_development_dependency "minitest-reporters"
  s.executables << "pandocomatic"
  s.homepage = "https://heerdebeer.org/Software/markdown/pandocomatic/"
  s.requirements << "pandoc, a universal document converer <http://pandoc.org>"
end
