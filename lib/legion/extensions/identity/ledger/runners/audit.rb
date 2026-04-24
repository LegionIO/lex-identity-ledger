# frozen_string_literal: true

module Legion
  module Extensions
    module Identity
      module Ledger
        module Runners
          module Audit
            extend self

            def write_audit(payload, _metadata = {})
              return { result: :skipped, reason: :already_persisted } if payload[:persisted]

              record = build_audit_record(payload)
              ::Legion::Data::DB[:audit_log].insert(record)

              { result: :ok }
            rescue StandardError => e
              Legion::Logging.error("[lex-identity-ledger] write_audit failed: #{e.message}") # rubocop:disable Legion/HelperMigration/DirectLogging
              { result: :error, error: e.message }
            end

            private

            def build_audit_record(payload)
              {
                event_type:     payload[:event_type].to_s,
                principal_id:   payload[:principal_id].to_s,
                principal_type: payload[:principal_type].to_s,
                action:         payload[:action].to_s,
                resource:       payload[:resource].to_s,
                source:         (payload[:source] || 'identity').to_s,
                node:           (payload[:node] || 'unknown').to_s,
                status:         (payload[:status] || 'success').to_s,
                duration_ms:    payload[:duration_ms],
                detail:         payload[:detail],
                record_hash:    payload[:record_hash].to_s,
                prev_hash:      payload[:prev_hash].to_s,
                created_at:     payload[:created_at] || Time.now.utc
              }
            end
          end
        end
      end
    end
  end
end
