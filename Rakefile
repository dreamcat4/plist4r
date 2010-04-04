require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "plist4r"
    gem.summary = %Q{Dreamcat4's plist4r gem. For reading/writing plists in ruby}
    gem.description = %Q{In development. Plist4R is a gem which is striving for 3 things: ease of use, speed, and reliability handling of plists. To help achieve these goals, we may plug-in or re-write this gem with one or several backends. Notably, we try to distinguish this gem by providing easy-to use DSL interface for users. For common plist type(s), such as convenience methods for Launchd Plist}
    gem.email = "dreamcat4@gmail.com"
    gem.homepage = "http://github.com/dreamcat4/plist4r"
    gem.authors = ["dreamcat4"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    gem.add_development_dependency "cucumber", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  task :features => :check_dependencies
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

Jeweler::GhpagesTasks.new do |ghpages|
  ghpages.push_on_release   = true
  ghpages.set_repo_homepage = true
  ghpages.user_github_com   = false
  ghpages.doc_task    = "yard"
  ghpages.keep_files  = []
  ghpages.map_paths   = {
    "doc" => "",
  }
end

