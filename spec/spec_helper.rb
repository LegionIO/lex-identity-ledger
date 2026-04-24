# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'sequel'
require_relative 'support/test_db'

module Legion
  module Extensions
    module Core
    end

    module Helpers
      module Lex
        def self.included(base)
          base
        end
      end
    end

    module Actors
      class Subscription # rubocop:disable Lint/EmptyClass
      end
    end

    module Transport
    end
  end

  module Transport
    class Exchange # rubocop:disable Lint/EmptyClass
    end

    class Queue # rubocop:disable Lint/EmptyClass
    end
  end

  module Logging
    def self.error(_msg) = nil
    def self.warn(_msg)  = nil
    def self.info(_msg)  = nil
    def self.debug(_msg) = nil
  end

  module JSON
    def self.dump(obj)
      require 'json'
      ::JSON.generate(obj)
    end

    def self.load(str, symbolize_names: false)
      require 'json'
      ::JSON.parse(str, symbolize_names: symbolize_names)
    end
  end

  module Data
    DB = TestDb.setup

    def self.db
      DB
    end
  end
end

$LOADED_FEATURES << 'legionio.rb'
$LOADED_FEATURES << 'legion/extensions/core.rb'
$LOADED_FEATURES << 'legion/extensions/actors/subscription'
$LOADED_FEATURES << 'legion/extensions/transport'
$LOADED_FEATURES << 'legion/transport/exchange.rb'
$LOADED_FEATURES << 'legion/transport/queue.rb'

lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'legion/extensions/identity/ledger/version'
require 'legion/extensions/identity/ledger/runners/identity'
require 'legion/extensions/identity/ledger/runners/audit'
require 'legion/extensions/identity/ledger/runners/groups'
require 'legion/extensions/identity/ledger/transport/queues/identity_write'
require 'legion/extensions/identity/ledger/transport/queues/audit_write'
require 'legion/extensions/identity/ledger/transport/queues/group_sync'
require 'legion/extensions/identity/ledger/transport/transport'
require 'legion/extensions/identity/ledger/actors/identity_writer'
require 'legion/extensions/identity/ledger/actors/audit_writer'
require 'legion/extensions/identity/ledger/actors/group_writer'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    # Delete child tables first to respect foreign key constraints
    Legion::Data::DB[:identities].delete
    Legion::Data::DB[:identity_group_memberships].delete
    Legion::Data::DB[:identity_groups].delete
    Legion::Data::DB[:identity_providers].delete
    Legion::Data::DB[:principals].delete
    Legion::Data::DB[:audit_log].delete
  end
end
