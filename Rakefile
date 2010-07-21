require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "plist4r"
    gem.summary = %Q{Dreamcat4's plist4r gem. For reading/writing plists in ruby}
    gem.description = %Q{Plist4r is for editing Plist files in an easy-to-use, fast, and reliabile way. A comprehensive and fully featured Ruby library. Xml and Binary file formats are supported, with backends for Linux and Mac.}
    gem.email = "dreamcat4@gmail.com"
    gem.homepage = "http://github.com/dreamcat4/plist4r"
    gem.authors = ["dreamcat4"]
    gem.add_dependency "libxml-ruby"
    gem.add_dependency "haml"
    gem.add_dependency "libxml4r"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    gem.add_development_dependency "cucumber", ">= 0"
    gem.files.include %w(lib/plist4r/cli.rb) # no idea why this file gets ommited
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

namespace :backends do
  task :compile do
    if File.exists? "/System/Library/Frameworks/CoreFoundation.framework"
      r = %x[rm ext/osx_plist/osx_plist.bundle lib/plist4r/backend/osx_plist/ext/osx_plist.bundle]
      puts r if r.length > 0
      puts %x[cd ext/osx_plist && ./extconf.rb && make clean && make]
      r = %x[cp ext/osx_plist/osx_plist.bundle lib/plist4r/backend/osx_plist/ext/osx_plist.bundle]
      puts r if r.length > 0
    end
  end

  task :test => :compile do
    require 'lib/plist4r'
    require 'plist4r/backend/test/output'
    o = Plist4r::Backend::Test::Output.new
    puts o
    o.write_html_file
    o.results_stdout
  end
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.after = lambda { `touch doc/.nojekyll` }
end

Jeweler::GhpagesTasks.new do |ghpages|
  ghpages.push_on_release   = true
  ghpages.set_repo_homepage = true
  ghpages.user_github_com   = false
  ghpages.doc_task    = "yard"
  ghpages.keep_files  = []
  ghpages.map_paths   = {
    ".nojekyll" => "",
    "doc" => "",
  }
end

