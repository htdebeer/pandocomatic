require "rake/testtask"

Rake::TestTask.new do |t|
  
  t.libs << "lib"
  t.libs << "lib/pandocomatic"
  t.test_files = FileList["test/test_helper.rb", "test/unit/*.rb", "test/spec/*.rb"]
  t.warning = true
  t.verbose = true
end

task :default => :test
