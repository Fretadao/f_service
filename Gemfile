# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in f_service.gemspec
gemspec

group :development, :test do
  gem 'rake', '~> 13.0.0'
  gem 'rubocop', '~> 0.81.0', require: false
  gem 'rubocop-rspec', require: false
end

group :optional do
  gem 'solargraph'
end

group :test do
  gem 'rspec', '~> 3.0'
end
