# ClientSuccess Ruby Client

This is an unofficial wrapper for the ClientSuccess
[Open API](http://docs.clientsuccessapi.apiary.io/)
and [Usage API](http://docs.clientsuccessusage.apiary.io/#introduction/events-api).

With respect to the Open API, this wrapper currently
supports the API endpoints for authentication, clients,
and contacts. Pull requests for other areas of the API very welcomed!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'client_success_ruby_client',
    git: 'git://github.com/LawKick/client_success_ruby_client.git'
```

And then execute:

    $ bundle

## Open API

Instantiate a client object using your ClientSuccess
email and password:

```ruby
api = ClientSuccess::OpenApi.new(email: 'myemail@bar.com', password: 'abc')
```

You can then use the client to access all available endpoints:

```ruby
clients = api.all_clients
# => array of all ClientSuccess clients
client = clients.first
# => a ClientSuccess::Resources::Client object
client.external_id
# => the client's externalId (note how accessor method is snake-cased)
```

All available API methods are well documented in the modules under
the ClientSuccess::OpenApi namespace. The quick and dirty is documented
below.

### Creating resources
To create a resource in ClientSuccess, you first must locally
instantiate an object for that resource using either a hash or manually
assigning the object's attributes. For example:

```ruby
attrs = { name: 'Foo Corp.',
          zendesk_id: '12345678',
          assigned_sales_rep: 'Bob Smith',
          ... }
client = ClientSuccess::Resources::Client.new(attrs)
client.tenant_id = 450
# And using our OpenApi client object from above...
api.create_client(client)
# => returns true if created, false if a 422 status response received
```

For contacts, ClientSuccess requires that you specify the contact's
corresponding client:

```ruby
contact = ClientSuccess::Resources::Contact.new
contact.name = 'Sarah Jones'
contact.email = 'sarah@jones.com'
contact.client_id = client.id
api.create_contact(contact)
```

Alternatively, you can manually specify the client in the API call:

```ruby
contact = ClientSuccess::Resources::Contact.new(some_attr_hash)
api.create_contact(contact, for_client: some_client)
# Note: 'some_client' can either be a Resources::Client
# or the client's id.
```

### Updating resources

Updating resources works in a similar fashion:

```ruby
# Must specify a client to retrieve a contact
contact = api.contact_from_id('1234', for_client: client)
# => returns a ClientSuccess::Resources::Client or nil
contact.name = 'Some new name'
api.update_contact_details(contact, for_client: client)
# => returns true or false
```

**NOTE:** There is a catch when juggling resources from
ClientSuccess and updating them. To update a resource, you
must have the *detailed* version of that resource. When getting,
say, a list of clients, you are receiving the *summary* of
those resources. To update any one of them, you must separately
request the detailed version of that resource, modify the resource,
and only then update it. E.g.:

```ruby
clients = api.all_clients
my_client = clients.find { |c| c.zendesk_id == 'abcdefg' }
# The below code fails (ClientSuccess will throw a 500 error)
my_client.zendesk_id = '123456'
api.update_client(my_client)
# But this will work...
my_detailed_client = api.client_from_id(my_client.id)
my_detailed_client.zendesk_id = '123456'
api.update_client(my_client)
```

A pull request to have the gem automatically handle this would
be swell. :)

### Destroying resources

```ruby
api.delete_contact(contact, for_client: client)
# => true or false (on 409 conflict status)
```

## Usage API

Unlike the Open API, the Usage API is instantiated using
a `project_id` and an `api_key` which is set for you by
ClientSuccess.
```ruby
usage_api = ClientSuccess::UsageApi.new(project_id: my_prj_id, api_key: my_api_key)
```

There is one endpoint available:
```ruby
# Where 'my_org' and 'my_user' are a ClientSuccess Client and Contact,
# which can be retrieved using the Open API discussed above.
usage_api.add_event('somethingneathappened', org: my_org, user: my_user)
# => true
```

## Rescuing API errors

Requests in this gem only rescue errors natural to the request, i.e.,
unprocessable entity error on creating/updating (returning false),
conflict on destroy (returning false), and not found on retrieving
a resource (returning nil). If you wish to rescue other errors
in your code (and you should), you can find the available errors in
the ClientSuccess::Errors module.

## Contributing

Open an [issue](https://github.com/LawKick/client_success_ruby_client/issues)
on Github for any questions, bug reports, or requests.

Pull requests very welcome, just make sure your code is tested and
that existing tests are passing (via 'appraisal rspec spec').

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
