Gem::Specification.new do |s|
  s.name = "pandocomatic"
  s.version = "0.0.9"
  s.license = "GPL3"
  s.summary = "Automate the use of pandoc"
  s.description = "Automate the use of pandoc <http://pandoc.org>: use pandocomatic as a makefile to convert one file, a whole directory of files, or even as a static site generator."
  s.author = "Huub de Beer"
  s.email = "Huub@heerdebeer.org"
  s.files = ["lib/pandocomatic/configuration.rb", 
             "lib/pandocomatic/default_configuration.yaml",
             "lib/pandocomatic/dir_converter.rb", 
             "lib/pandocomatic/file_converter.rb", 
             "lib/pandocomatic/pandoc_metadata.rb",
             "lib/pandocomatic/processor.rb",
             "lib/pandocomatic/fileinfo_preprocessor.rb"
            ]
  s.add_runtime_dependency "paru", "~> 0.0", ">= 0.0.1"
  s.add_runtime_dependency "trollop", "~> 2.0", ">= 2.0.0"
  s.executables << "pandocomatic"
  s.homepage = "https://github.com/htdebeer/pandocomatic"
  s.requirements << "pandoc, a universal document converer <http://pandoc.org>"
end
