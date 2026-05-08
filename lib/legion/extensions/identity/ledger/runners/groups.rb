# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Identity
      module Ledger
        module Runners
          module Groups
            extend self

            def write_group(payload, _metadata = {})
              return { result: :skipped, reason: :already_persisted } if payload[:persisted]

              now = Time.now.utc

              group_id = upsert_group(payload, now)
              return { result: :error, error: 'group upsert failed' } if group_id.nil?

              upsert_membership(payload, group_id, now) if payload[:principal_id]

              { result: :ok }
            rescue StandardError => e
              Legion::Logging.error("[lex-identity-ledger] write_group failed: #{e.message}") # rubocop:disable Legion/HelperMigration/DirectLogging
              { result: :error, error: e.message }
            end

            private

            def upsert_group(payload, now)
              row = {
                uuid:        SecureRandom.uuid,
                name:        payload[:group_name].to_s,
                source:      (payload[:source] || 'ldap').to_s,
                description: payload[:description],
                active:      true,
                created_at:  now,
                updated_at:  now
              }

              ds = ::Legion::Data::DB[:identity_groups]
              ds.insert_conflict(
                target: :name,
                update: { updated_at: now }
              ).insert(row)

              ds.where(name: row[:name]).get(:id)
            rescue StandardError => e
              Legion::Logging.error("[lex-identity-ledger] upsert_group failed: #{e.message}") # rubocop:disable Legion/HelperMigration/DirectLogging
              nil
            end

            def upsert_membership(payload, group_id, now)
              row = {
                uuid:          SecureRandom.uuid,
                principal_id:  payload[:principal_id],
                group_id:      group_id,
                status:        (payload[:membership_status] || 'active').to_s,
                discovered_by: (payload[:discovered_by] || payload[:source] || 'unknown').to_s,
                trust_weight:  payload[:trust_weight] || 50,
                expires_at:    payload[:expires_at],
                created_at:    now,
                updated_at:    now
              }

              ::Legion::Data::DB[:identity_group_memberships].insert_conflict(
                target: %i[principal_id group_id discovered_by],
                update: { status: row[:status], trust_weight: row[:trust_weight], updated_at: now }
              ).insert(row)
            rescue StandardError => e
              Legion::Logging.error("[lex-identity-ledger] upsert_membership failed: #{e.message}") # rubocop:disable Legion/HelperMigration/DirectLogging
              nil
            end
          end
        end
      end
    end
  end
end
