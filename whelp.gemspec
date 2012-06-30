# -*- encoding: utf-8 -*-
require File.expand_path('../lib/whelp/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["diebels727"]
  gem.email         = ["diebelsalternative@hotmail.com"]
  gem.description   = %q{A generalized business interface for you and your gems.}
  gem.summary       = %q{An extensible, adapter-based, interface to business-search providers.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "whelp"
  gem.require_paths = ["lib"]
  gem.version       = Whelp::VERSION
end
