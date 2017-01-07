require "rake/testtask"
require "yard"

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "lib/pandocomatic"
  t.test_files = FileList["test/test_helper.rb", "test/unit/*.rb", "test/spec/*.rb"]
  t.warning = true
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
end

task :default => :test
