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

  # Ship only what a consumer of the gem needs: the library, the docs and the
  # licence. Everything else tracked in the repository is development tooling and
  # was being packaged until now — CI workflows, git hooks, the Gemfile, and so on.
  development_only = %r{
    ^(bin|test|spec|features)/    # console/setup scripts and test suites
    | ^\.git                      # .gitignore, .github/, .githooks/
    | ^\.rubocop                  # linter configuration
    | ^(Gemfile|Rakefile)         # development entrypoints
    | ^CONTRIBUTING               # contributor documentation
    | release-please              # release automation configuration
  }x

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").grep_v(development_only)
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
