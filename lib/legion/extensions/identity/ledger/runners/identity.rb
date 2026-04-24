# frozen_string_literal: true

module Legion
  module Extensions
    module Identity
      module Ledger
        module Runners
          module Identity
            extend self

            def write_identity(payload, _metadata = {})
              return { result: :skipped, reason: :already_persisted } if payload[:persisted]

              now = Time.now.utc

              provider_id = upsert_provider(payload, now)
              return { result: :error, error: 'provider upsert failed' } if provider_id.nil?

              principal_id = upsert_principal(payload, now)
              return { result: :error, error: 'principal upsert failed' } if principal_id.nil?

              upsert_identity(payload, provider_id, principal_id, now)

              { result: :ok }
            rescue StandardError => e
              Legion::Logging.error("[lex-identity-ledger] write_identity failed: #{e.message}") # rubocop:disable Legion/HelperMigration/DirectLogging
              { result: :error, error: e.message }
            end

            private

            def upsert_provider(payload, now)
              row = {
                name:          payload[:source].to_s,
                provider_type: (payload[:provider_type] || 'authenticate').to_s,
                facing:        (payload[:facing] || 'both').to_s,
                priority:      payload[:priority] || 100,
                trust_weight:  payload[:trust_weight] || 50,
                enabled:       true,
                created_at:    now,
                updated_at:    now
              }

              ds = ::Legion::Data::DB[:identity_providers]
              ds.insert_conflict(
                target: :name,
                update: { updated_at: now }
              ).insert(row)

              ds.where(name: row[:name]).get(:id)
            rescue StandardError => e
              Legion::Logging.error("[lex-identity-ledger] upsert_provider failed: #{e.message}") # rubocop:disable Legion/HelperMigration/DirectLogging
              nil
            end

            def upsert_principal(payload, now)
              row = {
                canonical_name: payload[:canonical_name].to_s,
                kind:           (payload[:kind] || 'human').to_s,
                display_name:   payload[:display_name],
                active:         true,
                last_seen_at:   now,
                created_at:     now,
                updated_at:     now
              }

              ds = ::Legion::Data::DB[:principals]
              ds.insert_conflict(
                target: %i[canonical_name kind],
                update: { last_seen_at: now, updated_at: now }
              ).insert(row)

              ds.where(canonical_name: row[:canonical_name], kind: row[:kind]).get(:id)
            rescue StandardError => e
              Legion::Logging.error("[lex-identity-ledger] upsert_principal failed: #{e.message}") # rubocop:disable Legion/HelperMigration/DirectLogging
              nil
            end

            def upsert_identity(payload, provider_id, principal_id, now)
              row = {
                principal_id:          principal_id,
                provider_id:           provider_id,
                provider_identity:     payload[:provider_identity].to_s,
                active:                true,
                last_authenticated_at: now,
                created_at:            now,
                updated_at:            now
              }

              ::Legion::Data::DB[:identities].insert_conflict(
                target:         %i[provider_id provider_identity],
                conflict_where: { active: true },
                update:         { last_authenticated_at: now, updated_at: now }
              ).insert(row)
            rescue StandardError => e
              Legion::Logging.error("[lex-identity-ledger] upsert_identity failed: #{e.message}") # rubocop:disable Legion/HelperMigration/DirectLogging
              nil
            end
          end
        end
      end
    end
  end
end
