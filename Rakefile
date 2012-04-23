# -*-ruby-*-

require 'rake/clean'
require 'rake/testtask'
require 'bundler/gem_tasks'
gem 'rdoc'
require 'rdoc/task'

task default: [:test]

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
