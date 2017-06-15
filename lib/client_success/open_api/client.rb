require 'client_success/open_api/authentication'
require 'client_success/open_api/clients'
require 'client_success/open_api/contacts'

module ClientSuccess
  module OpenApi
    # The wrapper for Client Success Open API.
    #
    class Client < ClientSuccess::BaseClient
      include OpenApi::Authentication,
              OpenApi::Clients,
              OpenApi::Contacts

      API = { domain: 'https://api.clientsuccess.com',
              version: '1' }.freeze
      REQUIRED_INIT_PARAMS = %i(email password).freeze

      attr_reader :email, :password

      # @param [String] email
      # @param [String] password
      # @option [String] url
      #   Override the default API url. Useful for
      #   testing against a mock server.
      # @return [ClientSuccess::OpenApi::Client]
      #
      def initialize(opts = {})
        validate_init_opts(opts)
        @email = opts[:email]
        @password = opts[:password]
        @api_url = opts[:url]
      end

      def api_url
        @api_url || API[:domain]
      end

      protected

      def get(path, opts = {})
        connection.get do |req|
          req.url build_api_endpoint_for(path)
          if opts[:params].is_a?(Hash)
            opts[:params].each_pair do |k, v|
              req.params[k.to_s] = v
            end
          end
        end
      end

      def post(path, opts = {})
        connection.post do |req|
          req.url build_api_endpoint_for(path)
          req.headers['Content-Type'] = opts[:content_type] || CONTENT_TYPE
          req.body = JSON.generate(opts[:params])
        end
      end

      def put(path, opts = {})
        connection.put do |req|
          req.url build_api_endpoint_for(path)
          req.headers['Content-Type'] = opts[:content_type] || CONTENT_TYPE
          req.body = JSON.generate(opts[:params])
        end
      end

      def patch(path, opts = {})
        connection.patch do |req|
          req.url build_api_endpoint_for(path)
          req.headers['Content-Type'] = opts[:content_type] || CONTENT_TYPE
          req.body = JSON.generate(opts[:params])
        end
      end

      def delete(path)
        connection.delete do |req|
          req.url build_api_endpoint_for(path)
        end
      end

      private

      def validate_init_opts(opts)
        REQUIRED_INIT_PARAMS.each do |param|
          next if opts[param]
          raise ArgumentError,
                "#{self.class.name} must be initialized with '#{param}'"
        end
      end

      def connection
        @connection ||= Faraday.new(url: api_url) do |conn|
          conn.headers['Authorization'] = access_token
          apply_default_connection_opts_to(conn)
        end
      end

      def build_api_endpoint_for(path)
        "/v#{API[:version]}#{path}"
      end

      # Use or retrieve the access token from Client Success.
      # Will default to an empty string to avoid runtime errors
      # when testing with mock servers.
      #
      # @return [String]
      #
      def access_token
        @access_token ||=
          request_access_token(email, password)['access_token'] || ''
      end

      # ClientSuccess does not directly return the id of a newly
      # created object. Instead, it returns a header containing
      # the location path. This method extracts that id.
      #
      # @param [String] path
      # @return [Integer]
      #
      def extract_id_from_location_path(path)
        path.split('/').last.to_i
      end
    end
  end
end
