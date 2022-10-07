# require "bundler/gem_tasks"
require "rake/testtask"

# puts "Dir: #{File.expand_path('.')}"

Rake::TestTask.new(:test) do |t|
  require './lib/required'
  t.libs << "tests"
  # t.libs << "lib/required"
  t.test_files = FileList["tests/**/*_test.rb"]
end

task :default => :test
