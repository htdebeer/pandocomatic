require "rake/testtask"
require "yard"

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "lib/pandocomatic"
  t.test_files = FileList["test/test_helper.rb", "test/unit/*.rb", "test/spec/*.rb"]
  t.warning = false
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
end

task :generate_docs do
  sh %{
    cd documentation;
    pandocomatic --data-dir data-dir --config config.yaml --input manual.md --output ../index.md;
    pandocomatic --data-dir data-dir --config config.yaml --input README.md --output ../README.md
  }
end

task :build do
  sh "gem build pandocomatic.gemspec; mv *.gem releases"
  Rake::Task["generate_docs"].execute
end

task :default => :test
