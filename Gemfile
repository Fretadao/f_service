# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in f_service.gemspec
gemspec

group :development, :test do
  # Left the stdlib in Ruby 4.0 and are no longer default gems. Until now they
  # reached the lockfile as transitive dependencies of solargraph.
  gem 'benchmark' # Required by rubocop
  gem 'ostruct' # Required by rake
  gem 'pry'
  gem 'pry-nav'
  gem 'rake', '~> 13.4'
  gem 'rubocop', '~> 1.89.0', require: false
  gem 'rubocop-rspec', require: false
end

group :docs do
  gem 'yard'
end

group :development do
  gem 'ruby-lsp', require: false
end

group :test do
  gem 'rspec', '~> 3.13'
  gem 'simplecov', require: false
end
