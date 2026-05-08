# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Identity::Ledger::Runners::Groups do
  let(:principal_id) do
    Legion::Data::DB[:identity_principals].insert(
      uuid:           SecureRandom.uuid,
      canonical_name: 'miverso2',
      kind:           'human',
      active:         true,
      last_seen_at:   Time.now.utc,
      created_at:     Time.now.utc,
      updated_at:     Time.now.utc
    )
  end

  let(:payload) do
    {
      group_name:        'platform-engineers',
      source:            'ldap',
      description:       'Platform engineering team',
      principal_id:      principal_id,
      discovered_by:     'ldap',
      membership_status: 'active',
      trust_weight:      60
    }
  end

  describe '.write_group' do
    it 'upserts group and membership then returns ok' do
      result = described_class.write_group(payload)
      expect(result).to eq({ result: :ok })

      group = Legion::Data::DB[:identity_groups].first
      expect(group[:name]).to eq('platform-engineers')
      expect(group[:source]).to eq('ldap')

      membership = Legion::Data::DB[:identity_group_memberships].first
      expect(membership[:principal_id]).to eq(principal_id)
      expect(membership[:group_id]).to eq(group[:id])
      expect(membership[:discovered_by]).to eq('ldap')
    end

    it 'skips DB write when persisted flag is true' do
      payload[:persisted] = true
      result = described_class.write_group(payload)
      expect(result).to eq({ result: :skipped, reason: :already_persisted })
      expect(Legion::Data::DB[:identity_groups].count).to eq(0)
    end

    it 'creates group without membership when principal_id is nil' do
      payload.delete(:principal_id)
      result = described_class.write_group(payload)
      expect(result).to eq({ result: :ok })
      expect(Legion::Data::DB[:identity_groups].count).to eq(1)
      expect(Legion::Data::DB[:identity_group_memberships].count).to eq(0)
    end

    it 'handles duplicate group upserts gracefully' do
      described_class.write_group(payload)
      result = described_class.write_group(payload)
      expect(result).to eq({ result: :ok })
      expect(Legion::Data::DB[:identity_groups].count).to eq(1)
    end

    it 'does not crash on unexpected errors' do
      error_payload = {
        group_name:   'fail-group',
        source:       'ldap',
        principal_id: 999
      }
      allow(Legion::Data::DB).to receive(:[]).and_raise(StandardError, 'timeout')
      result = described_class.write_group(error_payload)
      expect(result[:result]).to eq(:error)
      # Inner rescue catches the DB error and returns nil,
      # which triggers the "group upsert failed" guard
      expect(result[:error]).to be_a(String)
    end
  end
end
