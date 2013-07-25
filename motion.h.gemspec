# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "motion.h"
  spec.version       = '0.0.3'
  spec.authors       = ["Dave Lee"]
  spec.email         = ['dave@kastiglione.com']
  spec.description   = 'Expose iOS system C libraries in RubyMotion'
  spec.summary       = 'Expose iOS system C libraries in RubyMotion'
  spec.homepage      = 'https://github.com/kastiglione/motion.h'
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
