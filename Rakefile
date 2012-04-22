# -*-ruby-*-

require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rubygems/package_task'

gem 'rdoc'
require 'rdoc/task'

require_relative 'lib/bwkfanboy/meta'
include Bwkfanboy

require_relative 'test/rake_git'

spec = Gem::Specification.new {|i|
  i.name = Meta::NAME
  i.version = `bin/#{i.name} -V`
  i.summary = 'A converter from a raw HTML to an Atom feed. You can use it to watch sites that do not provide its own feed'
  i.description = i.summary + '.'
  i.author = Meta::AUTHOR
  i.email = Meta::EMAIL
  i.homepage = Meta::HOMEPAGE

  i.platform = Gem::Platform::RUBY
  i.required_ruby_version = '>= 1.9.3'
  i.files = git_ls('.')

  i.executables = FileList['bin/*'].gsub(/^bin\//, '')
  
  i.test_files = FileList['test/test_*.rb']
  
  i.rdoc_options << '-m' << 'README.rdoc'
  i.extra_rdoc_files = FileList['doc/*']

  i.add_dependency('open4', '>= 1.1.0')
  i.add_development_dependency('git', '>= 1.2.5')
}

Gem::PackageTask.new(spec).define

task default: [:repackage]

RDoc::Task.new('html') do |i|
  i.main = 'README.rdoc'
  i.rdoc_files = FileList['README.rdoc', 'doc/*', 'lib/**/*.rb']
#  i.rdoc_files.exclude("lib/**/some-nasty-staff")
end

Rake::TestTask.new do |i|
  i.test_files = FileList['test/test_*.rb']
end

desc "Insert all 'requires' to speedup reload"
task :shotgunreq do
  sh "git grep 'require ' -- '*.rb' | awk -F: '{print $2}' | grep -v test | sort | uniq > shotgun.rb"
end
