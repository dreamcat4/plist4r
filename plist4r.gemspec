# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{plist4r}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["dreamcat4"]
  s.date = %q{2010-04-18}
  s.default_executable = %q{plist4r}
  s.description = %q{In development. Plist4R is a gem which is striving for 3 things: ease of use, speed, and reliability handling of plists. To help achieve these goals, we may plug-in or re-write this gem with one or several backends. Notably, we try to distinguish this gem by providing easy-to use DSL interface for users. For common plist type(s), such as convenience methods for Launchd Plist}
  s.email = %q{dreamcat4@gmail.com}
  s.executables = ["plist4r"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".gitignore",
    ".nojekyll",
    ".yardopts",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/plist4r",
    "features/plist4r.feature",
    "features/step_definitions/plist4r_steps.rb",
    "features/support/env.rb",
    "lib/plist4r.rb",
    "lib/plist4r/application.rb",
    "lib/plist4r/backend.rb",
    "lib/plist4r/backend/example.rb",
    "lib/plist4r/backend/haml.rb",
    "lib/plist4r/backend/libxml4r.rb",
    "lib/plist4r/backend/plutil.rb",
    "lib/plist4r/backend/ruby_cocoa.rb",
    "lib/plist4r/backend_base.rb",
    "lib/plist4r/commands.rb",
    "lib/plist4r/config.rb",
    "lib/plist4r/mixin.rb",
    "lib/plist4r/mixin/data_methods.rb",
    "lib/plist4r/mixin/mixlib_cli.rb",
    "lib/plist4r/mixin/mixlib_config.rb",
    "lib/plist4r/mixin/ordered_hash.rb",
    "lib/plist4r/mixin/popen4.rb",
    "lib/plist4r/mixin/ruby_stdlib.rb",
    "lib/plist4r/options.rb",
    "lib/plist4r/plist.rb",
    "lib/plist4r/plist_cache.rb",
    "lib/plist4r/plist_type.rb",
    "lib/plist4r/plist_type/info.rb",
    "lib/plist4r/plist_type/launchd.rb",
    "lib/plist4r/plist_type/plist.rb",
    "plist4r.gemspec",
    "plists/array_mini.xml",
    "plists/example_big_binary.plist",
    "plists/example_medium_binary_launchd.plist",
    "plists/example_medium_launchd.xml",
    "plists/mini.xml",
    "spec/examples.rb",
    "spec/plist4r/plist_spec.rb",
    "spec/plist4r_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "test.rb"
  ]
  s.homepage = %q{http://github.com/dreamcat4/plist4r}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Dreamcat4's plist4r gem. For reading/writing plists in ruby}
  s.test_files = [
    "spec/examples.rb",
    "spec/plist4r/plist_spec.rb",
    "spec/plist4r_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end

