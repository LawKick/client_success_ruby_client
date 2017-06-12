$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'client_success_ruby_client'
require 'webmock/rspec'

# Returns a JSON string.
#
# @param [String or Symbol] name
# @return [String]
#
def read_fixture(name)
  IO.read(File.dirname(__FILE__) + "/fixtures/#{name}.json")
end

# Parses a fixture into a Hash object.
#
# @param [String or Symbol] name
# @return [Hash]
#
def read_fixture_as_hash(name)
  JSON.parse(read_fixture(name))
end

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:post, 'https://api.clientsuccess.com/v1/auth')
      .with(body: { 'password' => 'foo', 'username' => 'foo@bar.com' },
            headers: { 'Content-Type' => 'application/x-www-form-urlencoded',
                       'User-Agent' => 'Faraday v0.12.1' })
      .to_return(status: 200,
                 body: read_fixture('auth_body'),
                 headers: read_fixture_as_hash('auth_headers'))

    stub_request(:get, 'https://api.clientsuccess.com/v1/clients')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4',
            })
      .to_return(status: 200,
                 body: read_fixture('clients'),
                 headers: {
                   'Content-Type' => 'application/json',
                   'Access-Control-Allow-Origin' => '*',
                   'Access-Control-Allow-Methods' => 'OPTIONS,GET,HEAD,POST,' \
                                                     'PUT,DELETE,TRACE,CONNECT',
                   'Content-Length' => '852',
                 })

    stub_request(:post, 'https://api.clientsuccess.com/v1/clients')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4',
              'Content-Type' => 'application/json'
            })
      .to_return(status: 201,
                 body: '',
                 headers: { 'Location' => '/clients/1300' })

    stub_request(:get, 'https://api.clientsuccess.com/v1/clients?externalId=ABC123')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 200, body: read_fixture('client'), headers: {})

    stub_request(:get, 'https://api.clientsuccess.com/v1/clients/1306')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 200, body: read_fixture('client'), headers: {})

    stub_request(:put, 'https://api.clientsuccess.com/v1/clients/1306')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 204, body: '', headers: {})

    stub_request(:patch, 'https://api.clientsuccess.com/v1/customfield/value/client/1306')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4',
              'Content-Type' => 'application/json'
            })
      .to_return(status: 200, body: '"Update successful"', headers: {})

    stub_request(:delete, 'https://api.clientsuccess.com/v1/clients/1306')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 204, body: '', headers: {})

    stub_request(:get, 'https://api.clientsuccess.com/v1/clients/1306/contacts')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 200, body: read_fixture('contacts'), headers: {})

    stub_request(:post, 'https://api.clientsuccess.com/v1/clients/1340/contacts')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4',
              'Content-Type' => 'application/json'
            })
      .to_return(status: 200,
                 body: '',
                 headers: { 'Location' => '/clients/1340/contacts/90' })
    stub_request(:get, 'https://api.clientsuccess.com/v1/clients/1306/contacts/89')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 200,
                 body: read_fixture('contact_summary'),
                 headers: {})
    stub_request(:delete, 'https://api.clientsuccess.com/v1/clients/1340/contacts/89')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 204, body: '', headers: {})
    stub_request(:get, 'https://api.clientsuccess.com/v1/contacts?' \
                       'email=foo@bar.com&externalClientId=abc')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 200,
                 body: read_fixture('contact'),
                 headers: { 'Content-Type' => 'application/json' })
    stub_request(:get,
                 'https://api.clientsuccess.com/v1/clients/1306/contacts/89/details')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 200, body: read_fixture('contact'), headers: {})
    stub_request(:put, 'https://api.clientsuccess.com/v1/clients/1340/contacts/89/details')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 204, body: '', headers: {})
    stub_request(:post, 'https://api.clientsuccess.com/v1/clients/1340/contacts/details')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4',
              'Content-Type' => 'application/json'
            })
      .to_return(status: 201,
                 body: '',
                 headers: { 'Location' => 'clients/1306/89' })
    stub_request(:get, 'https://api.clientsuccess.com/v1/contact-custom-fields')
      .with(headers: {
              'Authorization' => 'bc7b4279-9b7f-4a1f-8f46-d72e753cf4f4'
            })
      .to_return(status: 200,
                 headers: { 'Content-Type': 'application/json' },
                 body: read_fixture('custom_fields'))
    stub_request(:post,
                 'https://usage.clientsuccess.com/collector/1.0.0/projects/foo/events/some_event?api_key=bar')
      .with(headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200,
                 body: JSON.generate('created': true),
                 headers: { 'Content-Type': 'application/json' })
  end
end
