require "rake/testtask"
require "rdoc/task"

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "lib/pandocomatic"
  t.test_files = FileList["test/test_helper.rb", "test/unit/*.rb", "test/spec/*.rb"]
  t.warning = true
  t.verbose = true
end

Rake::RDocTask.new do |t|
  t.rdoc_files.include("lib/**/*.rb")
  t.rdoc_dir = "doc/api"
  t.title = "Pandocomatic API documentation"
end

task :default => :test
