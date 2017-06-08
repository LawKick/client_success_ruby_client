require 'spec_helper'

RSpec.describe ClientSuccess::ApiClient do
  let(:client) { described_class.new(email: email, password: pw) }
  let(:email) { 'foo@bar.com' }
  let(:pw) { 'foo' }
  describe 'initialization' do
    it 'should not raise error' do
      expect(client.email).to eq email
      expect(client.password).to eq pw
    end
    context 'when email not provided' do
      let(:email) { nil }
      it do
        expect { client }.to raise_error(ArgumentError)
      end
    end
    context 'when password not provided' do
      let(:pw) { nil }
      it do
        expect { client }.to raise_error(ArgumentError)
      end
    end
  end
  describe 'auth_token' do
    subject { client.send(:access_token) }
    it do
      expect(subject).to eq 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
    end
    context 'when unauthorized' do
      before do
        stub_request(:post, 'https://api.clientsuccess.com/v1/auth')
          .with(body: { 'password' => pw, 'username' => email },
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;' \
                                                'q=0.6,identity;q=0.3',
                           'Content-Type' => 'application/x-www-form-urlencoded',
                           'User-Agent' => 'Faraday v0.12.1' })
          .to_return(status: 401,
                     body: "\"{\\\"returnUrl\\\":null}\"",
                     headers: read_fixture_as_hash('auth_fail_headers'))
      end
      it do
        expect { subject }.to raise_error(ClientSuccess::Errors::Unauthorized)
      end
    end
    context 'when service unavailable' do
      before do
        stub_request(:post, 'https://api.clientsuccess.com/v1/auth')
          .with(body: { 'password' => pw, 'username' => email },
                headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;' \
                                                'q=0.6,identity;q=0.3',
                           'Content-Type' => 'application/x-www-form-urlencoded',
                           'User-Agent' => 'Faraday v0.12.1' })
          .to_return(status: 503,
                     body: 'Some message re service being down for maintenance',
                     headers: {})
      end
      it do
        expect { subject }
          .to raise_error(ClientSuccess::Errors::ServiceUnavailable)
      end
    end
  end
  describe 'all_clients' do
    subject { client.all_clients }
    it do
      expect(subject).to be_a Array
      expect(subject).not_to be_empty
    end
    it 'should return Resources::Client objects' do
      subject.each { |c| expect(c).to be_a ClientSuccess::Resources::Client }
    end
  end
  describe 'create_client' do
    subject { client.create_client(resource) }
    let(:resource) { ClientSuccess::Resources::Client.new(attrs) }
    let(:attrs) { read_fixture_as_hash('client_new') }
    it do
      expect(subject).to eq true
    end
    it do
      expect(resource.id).to be_nil
      subject
      expect(resource.id).to eq 1300
    end
    context 'when rejected' do
      before do
        stub_request(:post, 'https://api.clientsuccess.com/v1/clients')
          .to_return(status: 422, body: '', headers: {})
      end
      it do
        expect(subject).to eq false
      end
    end
  end
  describe 'client_from_external_id' do
    subject { client.client_from_external_id(id) }
    let(:resource) { ClientSuccess::Resources::Client.new(attrs) }
    let(:attrs) { read_fixture_as_hash('client') }
    context 'when client exists' do
      let(:id) { resource.external_id }
      it do
        res = subject
        expect(res).to be_a ClientSuccess::Resources::Client
        expect(res.id).to eq resource.id
      end
    end
    context 'when client does not exist' do
      let(:id) { 1234 }
      before do
        stub_request(:get, 'https://api.clientsuccess.com/v1/clients?externalId=1234')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
                })
          .to_return(status: 404, body: '', headers: {})
      end
      it do
        expect(subject).to be_nil
      end
    end
  end
  describe 'client_from_id' do
    subject { client.client_from_id(id) }
    let(:resource) { ClientSuccess::Resources::Client.new(attrs) }
    let(:attrs) { read_fixture_as_hash('client') }
    context 'when client exists' do
      let(:id) { resource.id }
      it do
        res = subject
        expect(res).to be_a ClientSuccess::Resources::Client
        expect(res.id).to eq resource.id
      end
    end
    context 'when client does not exist' do
      let(:id) { 1234 }
      before do
        stub_request(:get, 'https://api.clientsuccess.com/v1/clients/1234')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
                })
          .to_return(status: 404, body: '', headers: {})
      end
      it do
        expect(subject).to be_nil
      end
    end
  end
  describe 'update_client' do
    subject { client.update_client(resource) }
    let(:resource) { ClientSuccess::Resources::Client.new(attrs) }
    let(:attrs) { read_fixture_as_hash('client') }
    it { expect(subject).to eq true }
    context 'when fails' do
      before do
        stub_request(:put, 'https://api.clientsuccess.com/v1/clients/1306')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
                })
          .to_return(status: 422, body: '', headers: {})
      end
      it { expect(subject).to eq false }
    end
  end
  describe 'update_client_custom_field' do
    subject { client.update_client_custom_field(resource, cf) }
    let(:resource) { ClientSuccess::Resources::Client.new(attrs) }
    let(:attrs) { read_fixture_as_hash('client') }
    let(:cf) { { 'My Custom Field': 'foo bar' } }
    it { expect(subject).to eq true }
    context 'when fails' do
      before do
        stub_request(:patch, 'https://api.clientsuccess.com/v1/customfield/value/client/1306')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4',
                  'Content-Type' => 'application/json'
                })
          .to_return(status: 422, body: '', headers: {})
      end
      it { expect(subject).to eq false }
    end
  end
  describe 'delete_client' do
    subject { client.delete_client(id) }
    let(:resource) { ClientSuccess::Resources::Client.new(attrs) }
    let(:attrs) { read_fixture_as_hash('client') }
    let(:id) { resource.id }
    it { expect(subject).to eq true }
    context 'when id passed is a Client' do
      let(:id) { resource }
      it { expect(subject).to eq true }
    end
    context 'when fails' do
      let(:id) { 1234 }
      before do
        stub_request(:delete, 'https://api.clientsuccess.com/v1/clients/1234')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
                })
          .to_return(status: 409, body: '', headers: {})
      end
      it { expect(subject).to eq false }
    end
  end
  describe 'all_contacts_for' do
    subject { client.all_contacts_for(id) }
    let(:client_resource) { ClientSuccess::Resources::Client.new(client_attrs) }
    let(:client_attrs) { read_fixture_as_hash('client') }
    let(:id) { client_resource.id }
    it do
      expect(subject).to be_a Array
      expect(subject).not_to be_empty
    end
    it 'should return Resources::Client objects' do
      subject.each { |c| expect(c).to be_a ClientSuccess::Resources::Contact }
    end
    context 'when parameter is a Client' do
      let(:id) { client_resource }
      it do
        expect(subject).to be_a Array
        expect(subject).not_to be_empty
      end
      it 'should return Resources::Client objects' do
        subject.each { |c| expect(c).to be_a ClientSuccess::Resources::Contact }
      end
    end
  end
  describe 'create_contact' do
    subject { client.create_contact(contact) }
    let(:contact) { ClientSuccess::Resources::Contact.new(attrs) }
    let(:attrs) { read_fixture_as_hash('contact').tap { |h| h.delete('id') } }
    it do
      expect(subject).to eq true
    end
    it do
      expect(contact.id).to be_nil
      subject
      expect(contact.id).to eq 90
    end
    context 'when client specified' do
      subject { client.create_contact(contact, for_client: client_res) }
      let(:attrs) do
        read_fixture_as_hash('contact').tap do |h|
          h.delete_if { |k| %w(id clientId).include?(k) }
        end
      end
      let(:client_res) { ClientSuccess::Resources::Client.new(client_attrs) }
      let(:client_attrs) { read_fixture_as_hash('client').merge('id' => 1340) }
      it { expect(subject).to eq true }
      context 'by id' do
        let(:client_res) { 1340 }
        it { expect(subject).to eq true }
      end
    end
    context 'when client not specified' do
      let(:attrs) do
        read_fixture_as_hash('contact').tap do |h|
          h.delete_if { |k| %w(id clientId).include?(k) }
        end
      end
      it do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
    context 'when contact id provided' do
      let(:attrs) { read_fixture_as_hash('contact') }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
    context 'when not processable' do
      before do
        stub_request(:post, 'https://api.clientsuccess.com/v1/clients/1340/contacts')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4',
                  'Content-Type' => 'application/json'
                })
          .to_return(status: 422,
                     body: '',
                     headers: {})
      end
      it { expect(subject).to eq false }
    end
  end
  describe 'contact_from_id' do
    subject { client.contact_from_id(id, for_client: client_id) }
    let(:id) { 89 }
    let(:client_id) { 1306 }
    it do
      expect(subject).to be_a ClientSuccess::Resources::Contact
    end
    context 'using a Client object' do
      let(:client_id) do
        ClientSuccess::Resources::Client.new(read_fixture_as_hash('client'))
      end
      it do
        expect(subject).to be_a ClientSuccess::Resources::Contact
      end
    end
    context 'when contact does not exist' do
      let(:id) { 1234 }
      before do
        stub_request(:get,
                     'https://api.clientsuccess.com/v1/clients/1306/contacts/1234')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
                })
          .to_return(status: 404, body: '', headers: {})
      end
      it do
        expect(subject).to be_nil
      end
    end
  end
  describe 'delete_contact' do
    subject { client.delete_contact(contact) }
    let(:contact) { ClientSuccess::Resources::Contact.new(attrs) }
    let(:attrs) { read_fixture_as_hash('contact') }
    it do
      expect(subject).to eq true
    end
    context 'when client specified' do
      subject { client.delete_contact(contact, for_client: client_res) }
      let(:client_res) { ClientSuccess::Resources::Client.new(client_attrs) }
      let(:client_attrs) { read_fixture_as_hash('client').merge('id' => 1340) }
      it { expect(subject).to eq true }
      context 'by id' do
        let(:client_res) { 1340 }
        it { expect(subject).to eq true }
        context 'and contact by id' do
          let(:contact) { 89 }
          it { expect(subject).to eq true }
        end
      end
    end
    context 'when client not specified' do
      let(:attrs) do
        read_fixture_as_hash('contact').tap do |h|
          h.delete('clientId')
        end
      end
      it do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
    context 'when fails' do
      before do
        stub_request(:delete,
                     'https://api.clientsuccess.com/v1/clients/1340/contacts/89')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
                })
          .to_return(status: 409,
                     body: '',
                     headers: {})
      end
      it { expect(subject).to eq false }
    end
  end
  describe 'contact_from' do
    subject { client.contact_from(external_client_id: id, email: email) }
    let(:id) { 'abc' }
    let(:email) { 'foo@bar.com' }
    it do
      expect(subject).to be_a ClientSuccess::Resources::Contact
    end
    context 'when 404 raised' do
      before do
        stub_request(:get, 'https://api.clientsuccess.com/v1/contacts?' \
                           'email=foo@bar.com&externalClientId=abc')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
                })
          .to_return(status: 404,
                     body: '',
                     headers: {})
      end
      it do
        expect(subject).to be_nil
      end
    end
  end
  describe 'contact_details_from_id' do
    subject { client.contact_details_from_id(id, for_client: client_id) }
    let(:id) { 89 }
    let(:client_id) { 1306 }
    it do
      expect(subject).to be_a ClientSuccess::Resources::Contact
    end
    context 'using a Client object' do
      let(:client_id) do
        ClientSuccess::Resources::Client.new(read_fixture_as_hash('client'))
      end
      it do
        expect(subject).to be_a ClientSuccess::Resources::Contact
      end
    end
    context 'when contact does not exist' do
      let(:id) { 1234 }
      before do
        stub_request(
          :get,
          'https://api.clientsuccess.com/v1/clients/1306/contacts/1234/details'
        ).with(headers: {
                 'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
               }).to_return(status: 404, body: '', headers: {})
      end
      it do
        expect(subject).to be_nil
      end
    end
  end
  describe 'create_contact' do
    subject { client.create_contact(contact) }
    let(:contact) { ClientSuccess::Resources::Contact.new(attrs) }
    let(:attrs) { read_fixture_as_hash('contact').tap { |h| h.delete('id') } }
    it do
      expect(subject).to eq true
    end
    context 'when client specified' do
      subject { client.create_contact(contact, for_client: client_res) }
      let(:attrs) do
        read_fixture_as_hash('contact').tap do |h|
          h.delete_if { |k| %w(id clientId).include?(k) }
        end
      end
      let(:client_res) { ClientSuccess::Resources::Client.new(client_attrs) }
      let(:client_attrs) { read_fixture_as_hash('client').merge('id' => 1340) }
      it { expect(subject).to eq true }
      context 'by id' do
        let(:client_res) { 1340 }
        it { expect(subject).to eq true }
      end
    end
    context 'when client not specified' do
      let(:attrs) do
        read_fixture_as_hash('contact').tap do |h|
          h.delete_if { |k| %w(id clientId).include?(k) }
        end
      end
      it do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
    context 'when contact id provided' do
      let(:attrs) { read_fixture_as_hash('contact') }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
    context 'when not processable' do
      before do
        stub_request(:post, 'https://api.clientsuccess.com/v1/clients/1340/contacts')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4',
                  'Content-Type' => 'application/json'
                })
          .to_return(status: 422,
                     body: '',
                     headers: {})
      end
      it { expect(subject).to eq false }
    end
  end
  describe 'contact_from_id' do
    subject { client.contact_from_id(id, for_client: client_id) }
    let(:id) { 89 }
    let(:client_id) { 1306 }
    it do
      expect(subject).to be_a ClientSuccess::Resources::Contact
    end
    context 'using a Client object' do
      let(:client_id) do
        ClientSuccess::Resources::Client.new(read_fixture_as_hash('client'))
      end
      it do
        expect(subject).to be_a ClientSuccess::Resources::Contact
      end
    end
    context 'when contact does not exist' do
      let(:id) { 1234 }
      before do
        stub_request(:get,
                     'https://api.clientsuccess.com/v1/clients/1306/contacts/1234')
          .with(headers: {
                  'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
                })
          .to_return(status: 404, body: '', headers: {})
      end
      it do
        expect(subject).to be_nil
      end
    end
  end
  describe 'update_contact_details' do
    subject { client.update_contact_details(contact) }
    let(:contact) { ClientSuccess::Resources::Contact.new(attrs) }
    let(:attrs) { read_fixture_as_hash('contact') }
    it do
      expect(subject).to eq true
    end
    context 'when client specified' do
      subject { client.update_contact_details(contact, for_client: client_res) }
      let(:attrs) do
        read_fixture_as_hash('contact').tap do |h|
          h.delete_if { |k| 'clientId' == k }
        end
      end
      let(:client_res) { ClientSuccess::Resources::Client.new(client_attrs) }
      let(:client_attrs) { read_fixture_as_hash('client').merge('id' => 1340) }
      it { expect(subject).to eq true }
      context 'by id' do
        let(:client_res) { 1340 }
        it { expect(subject).to eq true }
      end
    end
    context 'when client not specified' do
      let(:attrs) do
        read_fixture_as_hash('contact').tap do |h|
          h.delete_if { |k| 'clientId' == k }
        end
      end
      it do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
    context 'when not processable' do
      before do
        stub_request(
          :put,
          'https://api.clientsuccess.com/v1/clients/1340/contacts/89/details'
        ).with(headers: {
                 'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4',
                 'Content-Type' => 'application/json'
               }).to_return(status: 422, body: '', headers: {})
      end
      it { expect(subject).to eq false }
    end
  end
  describe 'create_detailed_contact' do
    subject { client.create_detailed_contact(contact) }
    let(:contact) { ClientSuccess::Resources::Contact.new(attrs) }
    let(:attrs) { read_fixture_as_hash('contact').tap { |h| h.delete('id') } }
    it do
      expect(subject).to eq true
    end
    context 'when client specified' do
      subject { client.create_contact(contact, for_client: client_res) }
      let(:attrs) do
        read_fixture_as_hash('contact').tap do |h|
          h.delete_if { |k| %w(id clientId).include?(k) }
        end
      end
      let(:client_res) { ClientSuccess::Resources::Client.new(client_attrs) }
      let(:client_attrs) { read_fixture_as_hash('client').merge('id' => 1340) }
      it { expect(subject).to eq true }
      context 'by id' do
        let(:client_res) { 1340 }
        it { expect(subject).to eq true }
      end
    end
    context 'when client not specified' do
      let(:attrs) do
        read_fixture_as_hash('contact').tap do |h|
          h.delete_if { |k| %w(id clientId).include?(k) }
        end
      end
      it do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
    context 'when contact id provided' do
      let(:attrs) { read_fixture_as_hash('contact') }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
    context 'when not processable' do
      before do
        stub_request(
          :post,
          'https://api.clientsuccess.com/v1/clients/1340/contacts/details'
        ).with(headers: {
                 'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4',
                 'Content-Type' => 'application/json'
               }).to_return(status: 422, body: '', headers: {})
      end
      it { expect(subject).to eq false }
    end
  end
  describe 'contact_custom_fields' do
    subject { client.contact_custom_fields }
    it do
      expect(subject).to be_a Array
    end
    it do
      expect(subject).not_to be_empty
    end
    it do
      subject.each do |cf|
        expect(cf).to be_a ClientSuccess::Resources::CustomField
      end
    end
  end
end
