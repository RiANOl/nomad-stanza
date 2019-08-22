lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nomad/stanza/version'

Gem::Specification.new do |spec|
  spec.name          = 'nomad-stanza'
  spec.version       = Nomad::Stanza.version
  spec.authors       = ['Rianol Jou']
  spec.email         = ['rianol.jou@gmail.com']
  spec.summary       = 'Provide Nomad stanzas definition and serializer.'

  spec.files         = Dir['bin/*', '**/*.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.bindir        = 'bin'
  spec.require_paths = ['lib']

  spec.homepage      = 'https://github.com/RiANOl/nomad-stanza'
  spec.license       = 'MIT'

  spec.add_runtime_dependency 'dry-struct', '~> 1.0'
  spec.add_runtime_dependency 'hydrochlorb', '~> 0.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.8'

  spec.required_ruby_version = '>= 2.3'
end
