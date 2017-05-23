require 'spec_helper'

RSpec.describe ClientSuccess::Resources::CustomFieldValue do
  describe 'instantiation' do
    it 'processes correctly' do
      data = read_fixture_as_hash(:custom_field_value)
      cfv = described_class.new(data)
      expect(cfv.auto_sync).to eq data['autoSync']
      expect(cfv.id).to eq data['id']
      expect(cfv.field_id).to eq data['fieldId']
      expect(cfv.value_id).to eq data['valueId']
      expect(cfv.name).to eq data['name']
      expect(cfv.label).to eq data['label']
    end
  end
end
