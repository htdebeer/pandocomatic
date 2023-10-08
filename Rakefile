require 'rake/testtask'
require 'rubocop/rake_task'
require 'yard'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'lib/pandocomatic'
  t.test_files = FileList['test/test_helper.rb', 'test/unit/*.rb', 'test/spec/*.rb']
  t.warning = false
  t.verbose = true
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = ['lib/']
  t.fail_on_error = true
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
  t.stats_options = ['--list-undoc']
end

task :generate_docs do
  sh %(
    cd documentation;
    ../test/pandocomatic.rb --data-dir data-dir --config config.yaml --input manual.md --output ../index.md;
    ../test/pandocomatic.rb --data-dir data-dir --config config.yaml --input README.md --output ../README.md
    )
end

task :build do
  Rake::Task[:rubocop].execute
  Rake::Task[:test].execute
  Rake::Task[:yard].execute
  sh 'gem build pandocomatic.gemspec; mv *.gem releases'
  Rake::Task['generate_docs'].execute
end

task default: :test
