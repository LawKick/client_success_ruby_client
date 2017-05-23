require 'spec_helper'

RSpec.describe ClientSuccess::Resources::Contact do
  let(:client) { described_class.new(data) }
  let(:data) { read_fixture_as_hash(:contact) }
  describe 'instantiation' do
    it 'processes correctly' do
      expect(client.id).to eq data['id']
      expect(client.client_id).to eq data['clientId']
      expect(client.name).to eq data['name']
      expect(client.email).to eq data['email']
      expect(client.executive_sponsor).to eq data['executiveSponsor']
      expect(client.champion).to eq data['champion']
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
