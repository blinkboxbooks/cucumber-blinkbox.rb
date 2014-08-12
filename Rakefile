require "bundler/gem_tasks"

task :default => :build
task :build => :test
task :test => :spec

desc "Run all rspec tests"
begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
  end
rescue LoadError => e
  raise e
  task :spec do
    $stderr.puts "Please install rspec: `gem install rspec`"
  end
end

