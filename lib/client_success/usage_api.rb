require 'client_success/usage_api/client'

module ClientSuccess
  # Module to encapsulate the ClientSuccess Usage API.
  #
  module UsageApi
    # Syntatic sugar to create a new UsageApi::Client.
    # This method allows use of the library without
    # causing confusion between the API client class
    # (UsageApi::Client) and the concept of a client
    # resource (Resources::Client).
    #
    # @param [String] project_id
    # @param [String] api_key
    # @option [String] api_version
    #   Defaults to '1.0.0'
    # @return [ClientSuccess::UsageApi::Client]
    #
    # See ClientSuccess::UsageApi::Client for details.
    #
    def new(opts = {})
      ClientSuccess::UsageApi::Client.new(opts)
    end
    module_function :new
  end
end
