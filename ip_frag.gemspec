# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ip_frag/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["yafei Lee"]
  gem.email         = ["lyfi2003@gmail.com"]
  gem.description   = %q{ip frag tool}
  gem.summary       = %q{ip frag tool}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ip_frag"
  gem.require_paths = ["lib"]
  gem.version       = IPFrag::VERSION
  gem.add_dependency "DIY-pcap", ">= 0.3.7"
end
