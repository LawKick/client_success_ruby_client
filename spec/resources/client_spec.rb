require 'spec_helper'

RSpec.describe ClientSuccess::Resources::Client do
  let(:client) { described_class.new(data) }
  let(:data) { read_fixture_as_hash(:client) }
  describe 'instantiation' do
    it 'processes correctly' do
      expect(client.id).to eq data['id']
      expect(client.external_id).to eq data['externalId']
      expect(client.site_url).to eq data['siteUrl']
      expect(client.client_segment_id).to eq data['clientSegmentId']
      expect(client.tenant_id).to eq data['tenantId']
      expect(client.custom_field_values).to be_a Array
      expect(client.custom_field_values.size)
        .to eq data['customFieldValues'].size
      client.custom_field_values.each do |cfv|
        expect(cfv).to be_a ClientSuccess::Resources::CustomFieldValue
      end
    end
  end
  describe 'as_json' do
    subject { client.as_json }
    it 'renders all attributes to hash' do
      client.as_json['customFieldValues'].each do |v|
        expect(v).to be_a Hash
      end
    end
  end
end
