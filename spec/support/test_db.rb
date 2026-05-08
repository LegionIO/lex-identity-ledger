# frozen_string_literal: true

require 'sequel'

module TestDb
  module_function

  def setup # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    db = Sequel.sqlite

    db.create_table(:identity_providers) do
      primary_key :id
      String :uuid, size: 36, null: false, unique: true
      String :name, null: false, unique: true
      String :provider_type, null: false
      String :facing, null: false
      Integer :priority, null: false, default: 100
      Integer :trust_weight, null: false, default: 50
      String :source, null: false, default: 'gem'
      TrueClass :enabled, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    db.create_table(:identity_principals) do
      primary_key :id
      String :uuid, size: 36, null: false, unique: true
      String :canonical_name, null: false
      String :kind, null: false
      String :employee_key
      String :display_name
      TrueClass :active, null: false, default: true
      DateTime :last_seen_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique %i[canonical_name kind]
    end

    db.create_table(:identities) do
      primary_key :id
      String :uuid, size: 36, null: false, unique: true
      foreign_key :principal_id, :identity_principals, null: false
      foreign_key :provider_id, :identity_providers, null: false
      String :provider_identity_key, null: false
      String :profile_ciphertext
      TrueClass :active, null: false, default: true
      DateTime :last_authenticated_at
      String :account_type, null: false, default: 'primary'
      String :qualifier
      TrueClass :is_default, null: false, default: false
      String :link_evidence
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique %i[principal_id provider_id provider_identity_key]
    end

    db.create_table(:identity_groups) do
      primary_key :id
      String :uuid, size: 36, null: false, unique: true
      String :name, null: false, unique: true
      String :source, null: false, default: 'ldap'
      String :description
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    db.create_table(:identity_group_memberships) do
      primary_key :id
      String :uuid, size: 36, null: false, unique: true
      foreign_key :principal_id, :identity_principals, null: false
      foreign_key :group_id, :identity_groups, null: false
      String :status, null: false, default: 'active'
      String :discovered_by, null: false
      Integer :trust_weight, null: false, default: 50
      DateTime :expires_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique %i[principal_id group_id discovered_by]
    end

    db.create_table(:identity_audit_log) do
      primary_key :id
      String :uuid, size: 36, null: false, unique: true
      foreign_key :principal_id, :identity_principals, on_delete: :set_null
      foreign_key :identity_id, :identities, on_delete: :set_null
      String :provider_name, null: false
      String :event_type, null: false
      String :trust_level
      String :detail_payload
      String :node_ref
      String :session_ref
      DateTime :created_at, null: false
    end

    db.create_table(:audit_log) do
      primary_key :id
      String :event_type, null: false
      String :principal_id, null: false
      String :principal_type, null: false
      String :action, null: false
      String :resource, null: false
      String :source, null: false
      String :node, null: false
      String :status, null: false
      Integer :duration_ms
      column :detail, :text
      String :record_hash, null: false
      String :prev_hash, null: false
      DateTime :created_at, null: false
    end

    db
  end
end
