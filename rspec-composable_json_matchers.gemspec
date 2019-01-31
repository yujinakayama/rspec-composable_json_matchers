lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/composable_json_matchers/version'

Gem::Specification.new do |spec|
  spec.name          = 'rspec-composable_json_matchers'
  spec.version       = RSpec::ComposableJSONMatchers::Version.to_s
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']

  spec.summary       = 'RSpec matchers for JSON strings with the power of ' \
                       'built-in matchers and composable matchers'
  spec.homepage      = 'https://github.com/yujinakayama/rspec-composable_json_matchers'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'json', '~> 2.0'
  spec.add_runtime_dependency 'rspec', '~> 3.0'

  spec.add_development_dependency 'bundler', '>= 1.11'
end
