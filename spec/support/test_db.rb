# frozen_string_literal: true

require 'sequel'

module TestDb
  module_function

  def setup # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    db = Sequel.sqlite

    db.create_table(:identity_providers) do
      primary_key :id
      String :name, null: false, unique: true
      String :provider_type, null: false
      String :facing, null: false
      Integer :priority, null: false, default: 100
      Integer :trust_weight, null: false, default: 50
      TrueClass :enabled, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    db.create_table(:principals) do
      primary_key :id
      String :canonical_name, null: false
      String :kind, null: false
      String :display_name
      TrueClass :active, null: false, default: true
      DateTime :last_seen_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique %i[canonical_name kind]
    end

    db.create_table(:identities) do
      primary_key :id
      foreign_key :principal_id, :principals, null: false
      foreign_key :provider_id, :identity_providers, null: false
      String :provider_identity, null: false
      TrueClass :active, null: false, default: true
      DateTime :last_authenticated_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique %i[provider_id provider_identity]
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

    db.create_table(:identity_groups) do
      primary_key :id
      String :name, null: false, unique: true
      String :source, null: false, default: 'ldap'
      String :description
      TrueClass :active, null: false, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    db.create_table(:identity_group_memberships) do
      primary_key :id
      foreign_key :principal_id, :principals, null: false
      foreign_key :group_id, :identity_groups, null: false
      String :status, null: false, default: 'active'
      String :discovered_by, null: false
      Integer :trust_weight, null: false, default: 50
      DateTime :expires_at
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      unique %i[principal_id group_id discovered_by]
    end

    db
  end
end
