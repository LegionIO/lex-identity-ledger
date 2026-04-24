# frozen_string_literal: true

require 'legion/extensions/transport'

module Legion
  module Extensions
    module Identity
      module Ledger
        module Transport
          extend Legion::Extensions::Transport

          # Inline exchange class — the identity exchange is not yet defined in a core gem
          class IdentityExchange < Legion::Transport::Exchange
            def exchange_name
              'identity'
            end

            def exchange_type
              :topic
            end

            def exchange_options
              { durable: true }
            end
          end

          def self.additional_e_to_q
            [
              {
                from:        IdentityExchange,
                to:          Legion::Extensions::Identity::Ledger::Transport::Queues::IdentityWrite,
                routing_key: 'identity.write.#'
              },
              {
                from:        IdentityExchange,
                to:          Legion::Extensions::Identity::Ledger::Transport::Queues::AuditWrite,
                routing_key: 'identity.audit.#'
              },
              {
                from:        IdentityExchange,
                to:          Legion::Extensions::Identity::Ledger::Transport::Queues::GroupSync,
                routing_key: 'identity.group.#'
              }
            ]
          end
        end
      end
    end
  end
end
