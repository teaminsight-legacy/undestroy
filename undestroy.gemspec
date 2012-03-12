# -*- encoding: utf-8 -*-
require File.expand_path('../lib/undestroy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Travis Petticrew"]
  gem.email         = ["bobo@petticrew.net"]
  gem.description   = %q{Move AR records to alternate table on destroy and allow restoring.}
  gem.summary       = %q{Allow AR records to be undestroyed by archiving their data in a seperate table when destroying the original data}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "undestroy"
  gem.require_paths = ["lib"]
  gem.version       = Undestroy::VERSION

  gem.add_dependency 'activerecord', '~>3.0'

  gem.add_development_dependency 'assert', '~>0.7'
  gem.add_development_dependency 'assert-rails', '~>0.2'
end
