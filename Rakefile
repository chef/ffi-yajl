$LOAD_PATH << File.expand_path(File.join(File.dirname( __FILE__ ), "lib"))

require "rspec/core/rake_task"
require "rubygems/package_task"
require "rake/extensiontask"
require "ffi_yajl/version"

Dir[File.expand_path("../*gemspec", __FILE__)].reverse_each do |gemspec_path|
  gemspec = eval(IO.read(gemspec_path))
  Gem::PackageTask.new(gemspec).define
end

begin
  require "github_changelog_generator/task"
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.issues = false
    config.since_tag = "1.0.1"
    config.exclude_labels = %w{duplicate question invalid wontfix changelog_skip}
  end
rescue LoadError
  puts "no github-changelog-generator"
end

desc "Build it and ship it"
task ship: [:clean, :gem] do
  sh("git tag #{FFI_Yajl::VERSION}")
  sh("git push --tags")
  Dir[File.expand_path("../pkg/*.gem", __FILE__)].reverse_each do |built_gem|
    sh("gem push #{built_gem}")
  end
end

unix_gemspec = eval(File.read("ffi-yajl.gemspec"))

task :clean do
  sh "rm -f Gemfile.lock"
  sh "rm -rf pkg/* tmp/* .bundle lib/ffi_yajl/ext/*"
end

desc "install the gem locally"
task install: [:package] do
  if defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"
    sh %{gem install pkg/#{unix_gemspec.name}-#{unix_gemspec.version}-universal-java.gem}
  else
    sh %{gem install pkg/#{unix_gemspec.name}-#{unix_gemspec.version}.gem}
  end
end

spec = Gem::Specification.load("ffi-yajl.gemspec")

Rake::ExtensionTask.new do |ext|
  ext.name = "encoder"
  ext.lib_dir = "lib/ffi_yajl/ext"
  ext.ext_dir = "ext/ffi_yajl/ext/encoder"
  ext.gem_spec = spec
end

Rake::ExtensionTask.new do |ext|
  ext.name = "parser"
  ext.lib_dir = "lib/ffi_yajl/ext"
  ext.ext_dir = "ext/ffi_yajl/ext/parser"
  ext.gem_spec = spec
end

Rake::ExtensionTask.new do |ext|
  ext.name = "dlopen"
  ext.lib_dir = "lib/ffi_yajl/ext"
  ext.ext_dir = "ext/ffi_yajl/ext/dlopen"
  ext.gem_spec = spec
end

#
# test tasks
#

desc "Run all specs against both extensions"
task :spec do
  Rake::Task["spec:ffi"].invoke
  if !defined?(RUBY_ENGINE) || RUBY_ENGINE !~ /jruby/
    Rake::Task["spec:ext"].invoke
  end
end

namespace :spec do
  desc "Run all specs against ffi extension"
  RSpec::Core::RakeTask.new(:ffi) do |t|
    ENV["FORCE_FFI_YAJL"] = "ffi"
    t.pattern = FileList["spec/**/*_spec.rb"]
  end
  if !defined?(RUBY_ENGINE) || RUBY_ENGINE !~ /jruby/
    desc "Run all specs again c extension"
    RSpec::Core::RakeTask.new(:ext) do |t|
      ENV["FORCE_FFI_YAJL"] = "ext"
      t.pattern = FileList["spec/**/*_spec.rb"]
    end
  end
end

namespace :integration do
  begin
    require "kitchen"
  rescue LoadError
    task :vagrant do
      puts "test-kitchen gem is not installed"
    end
  else
    desc "Run Test Kitchen with Vagrant"
    task :vagrant do
      Kitchen.logger = Kitchen.default_file_logger
      Kitchen::Config.new.instances.each do |instance|
        instance.test(:always)
      end
    end
  end
end
namespace :style do
  desc "Run Ruby style checks"
  begin
    require "chefstyle"
    require "rubocop/rake_task"
  rescue LoadError
    task :rubocop do
      puts "chefstyle gem is not installed"
    end
  else
    RuboCop::RakeTask.new(:rubocop) do |t|
      t.fail_on_error = false
    end
  end
end

desc "Run all style checks"
task style: ["style:rubocop"]

desc "Run style + spec tests by default on travis"
task travis: %w{style spec}

desc "Run style + spec tests by default"
task default: %w{compile style spec}
