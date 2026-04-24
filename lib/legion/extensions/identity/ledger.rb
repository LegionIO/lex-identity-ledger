# frozen_string_literal: true

require_relative 'ledger/version'
require_relative 'ledger/runners/identity'
require_relative 'ledger/runners/audit'
require_relative 'ledger/runners/groups'

if Legion::Extensions.const_defined?(:Core, false)
  require_relative 'ledger/transport/queues/identity_write'
  require_relative 'ledger/transport/queues/audit_write'
  require_relative 'ledger/transport/queues/group_sync'
  require_relative 'ledger/transport/transport'
  require_relative 'ledger/actors/identity_writer'
  require_relative 'ledger/actors/audit_writer'
  require_relative 'ledger/actors/group_writer'
end

module Legion
  module Extensions
    module Identity
      module Ledger
        extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core, false)

        def self.data_required? # rubocop:disable Legion/Extension/DataRequiredWithoutMigrations
          true
        end

        def data_required?
          true
        end
      end
    end
  end
end
