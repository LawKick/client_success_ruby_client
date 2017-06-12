require 'client_success/open_api/client'

module ClientSuccess
  # Module to encapsulate the ClientSuccess Open API.
  #
  module OpenApi
    # Syntatic sugar to create a new OpenApi::Client.
    # This method allows use of the library without
    # causing confusion between the API client class
    # (OpenApi::Client) and the concept of a client
    # resource (Resources::Client or Open::Api::Clients).
    #
    # @param [String] email
    # @param [String] password
    # @option [String] url
    #   Override the default API url. Useful for
    #   testing against a mock server.
    # @return [ClientSuccess::OpenApi::Client]
    #
    # See ClientSuccess::OpenApi::Client for further
    # details.
    #
    def new(opts = {})
      ClientSuccess::OpenApi::Client.new(opts)
    end
    module_function :new
  end
end
