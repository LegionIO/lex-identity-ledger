# frozen_string_literal: true

require 'legion/extensions/actors/subscription'

module Legion
  module Extensions
    module Identity
      module Ledger
        module Actor
          class AuditWriter < Legion::Extensions::Actors::Subscription
            def runner_class = Legion::Extensions::Identity::Ledger::Runners::Audit

            def runner_function
              'write_audit'
            end

            def use_runner?
              false
            end
          end
        end
      end
    end
  end
end
