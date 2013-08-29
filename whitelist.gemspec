# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whitelist/version'

Gem::Specification.new do |gem|
  gem.name          = "whitelist"
  gem.version       = Whitelist::VERSION
  gem.authors       = ["Dave Martin"]
  gem.email         = ["dmarti21@gmail.com"]
  gem.description   = %q{Simple whitelist checker}
  gem.summary       = %q{Simple whitelist checker}
  gem.homepage      = ""
  gem.add_development_dependency "rspec"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
