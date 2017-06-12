require 'spec_helper'

RSpec.describe ClientSuccess::UsageApi::Client do
  let(:client) { described_class.new(project_id: pid, api_key: api_key) }
  let(:pid) { 'foo' }
  let(:api_key) { 'bar' }
  describe 'initialization' do
    it 'should not err' do
      expect(client.project_id).to eq pid
      expect(client.api_key).to eq api_key
    end
    context 'using module function' do
      it 'should not err' do
        c = ClientSuccess::UsageApi.new(project_id: pid, api_key: api_key)
        expect(c).to be_a described_class
        expect(c.project_id).to eq pid
        expect(c.api_key).to eq api_key
      end
    end
    context 'when project_id not provided' do
      let(:pid) { nil }
      it do
        expect { client }.to raise_error(ArgumentError)
      end
    end
    context 'when api_key not provided' do
      let(:api_key) { nil }
      it do
        expect { client }.to raise_error(ArgumentError)
      end
    end
  end
  describe 'add_event' do
    subject { client.add_event(event_id, org: org, user: user) }
    let(:org) { ClientSuccess::Resources::Client.new(org_attrs) }
    let(:org_attrs) { read_fixture_as_hash('client') }
    let(:user) { ClientSuccess::Resources::Contact.new(user_attrs) }
    let(:user_attrs) { read_fixture_as_hash('contact') }
    let(:event_id) { 'some_event' }
    it do
      expect(subject).to eq true
    end
    context 'when fails' do
      it do
        # Presuming that ClientSuccess will respond with a 422
        # and a body with { created: false }...
        stub_request(:post,
                     'https://usage.clientsuccess.com/collector/1.0.0/projects/foo/events/some_event?api_key=bar')
          .with(headers: { 'Content-Type' => 'application/json' })
          .to_return(status: 422,
                     body: JSON.generate('created': false),
                     headers: { 'Content-Type': 'application/json' })
        expect(subject).to eq false
      end
    end
  end
end
