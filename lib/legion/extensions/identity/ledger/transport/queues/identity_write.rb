# frozen_string_literal: true

module Legion
  module Extensions
    module Identity
      module Ledger
        module Transport
          module Queues
            class IdentityWrite < Legion::Transport::Queue
              def queue_name
                'identity.write'
              end

              def queue_options
                { durable: true }
              end
            end
          end
        end
      end
    end
  end
end
