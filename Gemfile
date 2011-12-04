source 'http://rubygems.org'
require 'rbconfig'
HOST_OS = RbConfig::CONFIG['host_os']

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'rspec'
  gem 'yard'
  gem 'bundler'
  gem 'jeweler'
  gem 'simplecov'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'guard-yard'
  gem 'redcarpet'

  if HOST_OS =~ /linux/i
    gem 'rb-inotify', require: false
    gem 'libnotify', require: false
  end
end
