# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'f_service/version'

Gem::Specification.new do |spec|
  spec.name    = 'f_service'
  spec.version = FService::VERSION
  spec.authors = ['Fretadao Tech Team']
  spec.email = ['tech@fretadao.com.br']

  spec.summary     = 'A small, monad-based service class'
  spec.description = <<-DESCRIPTION
    FService is a small gem that provides a base class for your services (aka operations).
    The goal is to make services simpler, safer and more composable.
    It uses the Result monad for handling operations.
  DESCRIPTION

  spec.homepage = 'https://github.com/Fretadao/f_service'
  spec.license  = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Fretadao/f_service'
  spec.metadata['documentation_uri'] = 'https://www.rubydoc.info/gems/f_service'
  spec.metadata['changelog_uri'] = 'https://github.com/Fretadao/f_service/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
