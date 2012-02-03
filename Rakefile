require 'bundler'
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'microsoft_ngram'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec