require 'rspec/core/rake_task'
require 'rubygems/package_task'
require 'rake/extensiontask'

Dir[File.expand_path("../*gemspec", __FILE__)].reverse.each do |gemspec_path|
  gemspec = eval(IO.read(gemspec_path))
  Gem::PackageTask.new(gemspec).define
end

require 'ffi_yajl/version'

desc "Run all specs against both extensions"
task :spec do
  Rake::Task["spec:ffi"].invoke
  Rake::Task["spec:ext"].invoke
end

namespace :spec do
  desc "Run all specs against ffi extension"
  RSpec::Core::RakeTask.new(:ffi) do |t|
    ENV['FORCE_FFI_YAJL'] = "ffi"
    t.pattern = FileList['spec/**/*_spec.rb']
  end
  if RUBY_VERSION.to_f >= 1.9 && RUBY_ENGINE !~ /jruby/
    desc "Run all specs again c extension"
    RSpec::Core::RakeTask.new(:ext) do |t|
      ENV['FORCE_FFI_YAJL'] = "ext"
      t.pattern = FileList['spec/**/*_spec.rb']
    end
  end
end

desc "Build it and ship it"
task :ship => [:clean, :gem] do
  sh("git tag #{Mixlib::ShellOut::VERSION}")
  sh("git push --tags")
  Dir[File.expand_path("../pkg/*.gem", __FILE__)].reverse.each do |built_gem|
    sh("gem push #{built_gem}")
  end
end

unix_gemspec = eval(File.read("ffi-yajl.gemspec"))

task :clean do
  sh "rm -rf pkg/* lib/ffi_yajl/ext/*"
end

desc "install the gem locally"
task :install => [:package] do
  if defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"
    sh %{gem install pkg/#{unix_gemspec.name}-#{unix_gemspec.version}-universal-java.gem}
  else
    sh %{gem install pkg/#{unix_gemspec.name}-#{unix_gemspec.version}.gem}
  end
end

spec = Gem::Specification.load('ffi-yajl.gemspec')

Rake::ExtensionTask.new do |ext|
  ext.name = 'libyajl'
  ext.lib_dir = 'lib'
  ext.ext_dir = 'ext/libyajl2'
  ext.gem_spec = spec
end

Rake::ExtensionTask.new do |ext|
  ext.name = 'encoder'
  ext.lib_dir = 'lib/ffi_yajl/ext'
  ext.ext_dir = 'ext/ffi_yajl/ext/encoder'
  ext.gem_spec = spec
end

Rake::ExtensionTask.new do |ext|
  ext.name = 'parser'
  ext.lib_dir = 'lib/ffi_yajl/ext'
  ext.ext_dir = 'ext/ffi_yajl/ext/parser'
  ext.gem_spec = spec
end
