# $LOAD_PATH << File.expand_path(File.join(File.dirname( __FILE__ ), "lib"))
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rspec/core/rake_task"
require "rubygems/package_task"
require "rake/extensiontask"
require "ffi_yajl/version"

Dir[File.expand_path("*gemspec", __dir__)].reverse_each do |gemspec_path|
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
task ship: %i{clean gem} do
  sh("git tag #{FFI_Yajl::VERSION}")
  sh("git push --tags")
  Dir[File.expand_path("pkg/*.gem", __dir__)].reverse_each do |built_gem|
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

desc "Check Linting and code style."
task :style do
  require "rubocop/rake_task"
  require "cookstyle/chefstyle"

  if RbConfig::CONFIG["host_os"] =~ /mswin|mingw|cygwin/
    # Windows-specific command, rubocop erroneously reports the CRLF in each file which is removed when your PR is uploaeded to GitHub.
    # This is a workaround to ignore the CRLF from the files before running cookstyle.
    sh "cookstyle --chefstyle -c .rubocop.yml --except Layout/EndOfLine"
  else
    sh "cookstyle --chefstyle -c .rubocop.yml"
  end
rescue LoadError
  puts "Rubocop or Cookstyle gems are not installed. bundle install first to make sure all dependencies are installed."
end

desc "Run style + spec tests by default on travis"
task buildkite: %w{style spec}

desc "Run style + spec tests by default"
task default: %w{compile style spec}
