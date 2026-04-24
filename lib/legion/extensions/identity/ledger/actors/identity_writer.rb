# frozen_string_literal: true

require 'legion/extensions/actors/subscription'

module Legion
  module Extensions
    module Identity
      module Ledger
        module Actor
          class IdentityWriter < Legion::Extensions::Actors::Subscription
            def runner_class = Legion::Extensions::Identity::Ledger::Runners::Identity

            def runner_function
              'write_identity'
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
