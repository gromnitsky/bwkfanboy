# -*-ruby-*-
require File.expand_path('../lib/bwkfanboy/meta', __FILE__)
include Bwkfanboy

Gem::Specification.new do |gem|
  gem.authors       = [Meta::NAME]
  gem.email         = [Meta::EMAIL]
  gem.description   = 'A converter from a raw HTML to an Atom feed. You can use it to watch sites that do not provide its own feed'
  gem.summary       = gem.description + '.'
  gem.homepage      = Meta::HOMEPAGE

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^test/test_.+\.rb})
  gem.name          = Meta::NAME
  gem.version       = Meta::VERSION

  gem.required_ruby_version = '>= 1.9.2'
  gem.extra_rdoc_files      = gem.files.grep(%r{^doc/})
  gem.rdoc_options          << '-m' << 'README.rdoc'

  gem.post_install_message  = <<-MESSAGE
This version was rewritten from scratch.
Plugins from & for previous versions (0.x & 1.x) WILL NOT WORK.

See also doc/NEWS.rdoc file.
  MESSAGE

  gem.add_dependency "open4", "~> 1.3.0"
  gem.add_dependency "msgpack", "~> 0.4.6"
  gem.add_dependency "rake", "~> 0.9.2.2"
  gem.add_dependency "nokogiri", "~> 1.5.2"
  gem.add_dependency "sinatra", "~> 1.3.2"
  gem.add_dependency "haml", "~> 3.1.4"
  gem.add_dependency "rdoc", "~> 3.12"
  
  gem.add_development_dependency "minitest", "~> 2.12.1"
  gem.add_development_dependency "fakefs", "~> 0.4.0"
  gem.add_development_dependency "rack-test", "~> 0.6.1"
end
