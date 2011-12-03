# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wikilink-converter}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Ian Yang}]
  s.date = %q{2011-12-04}
  s.description = %q{convert [[WikiLink]] to <a>}
  s.email = %q{me@iany.me}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".yardopts",
    "Gemfile",
    "Gemfile.lock",
    "Guardfile",
    "LICENSE.txt",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "lib/wikilink-converter.rb",
    "lib/wikilink/converter.rb",
    "lib/wikilink/converter/namespace.rb",
    "lib/wikilink/converter/site.rb",
    "lib/wikilink/converter/sites/ruby_china.rb",
    "lib/wikilink/converter/sites/wikipedia.rb",
    "lib/wikilink/converter/utils.rb",
    "spec/spec_helper.rb",
    "spec/support/matchers.rb",
    "spec/wikilink/converter/namespace_spec.rb",
    "spec/wikilink/converter/site_spec.rb",
    "spec/wikilink/converter/sites/ruby_china_spec.rb",
    "spec/wikilink/converter/sites/wikipedia_spec.rb",
    "spec/wikilink/converter_spec.rb",
    "wikilink-converter.gemspec"
  ]
  s.homepage = %q{http://github.com/doitian/wikilink-converter}
  s.licenses = [%q{MIT}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{convert [[WikiLink]] to <a>}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<guard>, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
      s.add_development_dependency(%q<guard-bundler>, [">= 0"])
      s.add_development_dependency(%q<guard-yard>, [">= 0"])
      s.add_development_dependency(%q<redcarpet>, [">= 0"])
      s.add_development_dependency(%q<rb-inotify>, [">= 0"])
      s.add_development_dependency(%q<libnotify>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<guard>, [">= 0"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
      s.add_dependency(%q<guard-bundler>, [">= 0"])
      s.add_dependency(%q<guard-yard>, [">= 0"])
      s.add_dependency(%q<redcarpet>, [">= 0"])
      s.add_dependency(%q<rb-inotify>, [">= 0"])
      s.add_dependency(%q<libnotify>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<guard>, [">= 0"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
    s.add_dependency(%q<guard-bundler>, [">= 0"])
    s.add_dependency(%q<guard-yard>, [">= 0"])
    s.add_dependency(%q<redcarpet>, [">= 0"])
    s.add_dependency(%q<rb-inotify>, [">= 0"])
    s.add_dependency(%q<libnotify>, [">= 0"])
  end
end

