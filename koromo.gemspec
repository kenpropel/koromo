$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'koromo/version'


Gem::Specification.new do |s|
  s.name          = 'koromo'
  s.version       = Koromo::Version
  s.authors       = ['Ken J.']
  s.email         = ['kenjij@gmail.com']
  s.summary       = 'MS-SQL Server web access proxy/bridge'
  s.description   = 'A web proxy/bridge server for MS-SQL Server to allow query via HTTP.'
  s.homepage      = 'https://github.com/kenjij/koromo'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.5'
  s.add_runtime_dependency 'kajiki', '~> 1.2'
  s.add_runtime_dependency 'sinatra', '~> 2.1'
  s.add_runtime_dependency 'tiny_tds', '~> 2.1'
end
