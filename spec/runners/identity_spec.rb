# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Identity::Ledger::Runners::Identity do
  let(:payload) do
    {
      canonical_name:    'miverso2',
      kind:              'human',
      display_name:      'Matt Iverson',
      source:            'kerberos',
      provider_type:     'authenticate',
      facing:            'human',
      provider_identity: 'miverso2@MS.DS.UHC.COM',
      priority:          10,
      trust_weight:      80
    }
  end

  describe '.write_identity' do
    it 'upserts provider, principal, and identity then returns ok' do
      result = described_class.write_identity(payload)
      expect(result).to eq({ result: :ok })

      provider = Legion::Data::DB[:identity_providers].first
      expect(provider[:name]).to eq('kerberos')
      expect(provider[:provider_type]).to eq('authenticate')

      principal = Legion::Data::DB[:identity_principals].first
      expect(principal[:canonical_name]).to eq('miverso2')
      expect(principal[:kind]).to eq('human')

      identity = Legion::Data::DB[:identities].first
      expect(identity[:provider_identity_key]).to eq('miverso2@MS.DS.UHC.COM')
      expect(identity[:active]).to be(true)
    end

    it 'skips DB write when persisted flag is true' do
      payload[:persisted] = true
      result = described_class.write_identity(payload)
      expect(result).to eq({ result: :skipped, reason: :already_persisted })
      expect(Legion::Data::DB[:identity_providers].count).to eq(0)
    end

    it 'handles duplicate upserts gracefully' do
      described_class.write_identity(payload)
      result = described_class.write_identity(payload)
      expect(result).to eq({ result: :ok })
      expect(Legion::Data::DB[:identity_providers].count).to eq(1)
      expect(Legion::Data::DB[:identity_principals].count).to eq(1)
    end

    it 'uses default values for optional fields' do
      minimal = {
        canonical_name:    'svc-deploy',
        source:            'system',
        provider_identity: 'svc-deploy'
      }
      result = described_class.write_identity(minimal)
      expect(result).to eq({ result: :ok })

      provider = Legion::Data::DB[:identity_providers].first
      expect(provider[:provider_type]).to eq('authenticate')
      expect(provider[:facing]).to eq('both')

      principal = Legion::Data::DB[:identity_principals].first
      expect(principal[:kind]).to eq('human')
    end

    it 'does not crash on unexpected errors' do
      allow(Legion::Data::DB).to receive(:[]).and_raise(StandardError, 'connection lost')
      result = described_class.write_identity(payload)
      expect(result[:result]).to eq(:error)
      # Inner rescue catches the DB error and returns nil,
      # which triggers the "provider upsert failed" guard
      expect(result[:error]).to be_a(String)
    end
  end
end
