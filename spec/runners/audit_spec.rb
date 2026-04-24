# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Identity::Ledger::Runners::Audit do
  let(:payload) do
    {
      event_type:     'identity.resolve',
      principal_id:   'miverso2',
      principal_type: 'human',
      action:         'resolve',
      resource:       'identity_pipeline',
      source:         'kerberos',
      node:           'laptop-matt-01',
      status:         'success',
      duration_ms:    42,
      detail:         'resolved via kerberos principal',
      record_hash:    'abc123def456',
      prev_hash:      '000000000000',
      created_at:     Time.now.utc
    }
  end

  describe '.write_audit' do
    it 'inserts an audit record and returns ok' do
      result = described_class.write_audit(payload)
      expect(result).to eq({ result: :ok })

      row = Legion::Data::DB[:audit_log].first
      expect(row[:event_type]).to eq('identity.resolve')
      expect(row[:principal_id]).to eq('miverso2')
      expect(row[:action]).to eq('resolve')
      expect(row[:duration_ms]).to eq(42)
    end

    it 'skips DB write when persisted flag is true' do
      payload[:persisted] = true
      result = described_class.write_audit(payload)
      expect(result).to eq({ result: :skipped, reason: :already_persisted })
      expect(Legion::Data::DB[:audit_log].count).to eq(0)
    end

    it 'appends multiple records (no conflict handling)' do
      described_class.write_audit(payload)
      payload[:record_hash] = 'second_hash'
      payload[:prev_hash]   = 'abc123def456'
      described_class.write_audit(payload)
      expect(Legion::Data::DB[:audit_log].count).to eq(2)
    end

    it 'does not crash on unexpected errors' do
      allow(Legion::Data::DB).to receive(:[]).and_raise(StandardError, 'disk full')
      result = described_class.write_audit(payload)
      expect(result[:result]).to eq(:error)
      expect(result[:error]).to include('disk full')
    end

    it 'uses default source and node when not provided' do
      payload.delete(:source)
      payload.delete(:node)
      result = described_class.write_audit(payload)
      expect(result).to eq({ result: :ok })

      row = Legion::Data::DB[:audit_log].first
      expect(row[:source]).to eq('identity')
      expect(row[:node]).to eq('unknown')
    end
  end
end
