# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "wikilink-converter"
  gem.homepage = "http://github.com/doitian/wikilink-converter"
  gem.license = "MIT"
  gem.summary = %Q{convert [[WikiLink]] to <a>}
  gem.description = %Q{convert [[WikiLink]] to <a>}
  gem.email = "me@iany.me"
  gem.authors = ["Ian Yang"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :cov do
  system 'bundle exec rake COVERAGE=1 spec'
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
