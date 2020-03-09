# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new do |task|
  task.verbose = false
end

RuboCop::RakeTask.new

task default: %i[spec rubocop]

if RUBY_VERSION >= '2.3'
  task ci: %i[spec rubocop]
else
  task ci: :spec
end
