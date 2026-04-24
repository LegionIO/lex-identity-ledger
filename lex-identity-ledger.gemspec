# frozen_string_literal: true

require_relative 'lib/legion/extensions/identity/ledger/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-identity-ledger'
  spec.version       = Legion::Extensions::Identity::Ledger::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Identity: Ledger persistence'
  spec.description   = 'LegionIO identity event persistence — consumes identity resolution, ' \
                       'audit, and group membership events from RabbitMQ transport and writes to Postgres'
  spec.homepage      = 'https://github.com/LegionIO/lex-identity-ledger'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/LegionIO/lex-identity-ledger'
  spec.metadata['documentation_uri']     = 'https://github.com/LegionIO/lex-identity-ledger'
  spec.metadata['changelog_uri']         = 'https://github.com/LegionIO/lex-identity-ledger'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/LegionIO/lex-identity-ledger/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,sig}/**/*') + %w[lex-identity-ledger.gemspec Gemfile LICENSE]
  end
  spec.require_paths = ['lib']

  # Core framework dependencies
  spec.add_dependency 'legion-json',     '>= 1.2'
  spec.add_dependency 'legion-settings', '>= 1.3'
end
