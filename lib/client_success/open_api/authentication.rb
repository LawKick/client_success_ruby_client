module ClientSuccess
  module OpenApi
    # Methods to retrieve a Client Success access token.
    # See:
    # http://docs.clientsuccessapi.apiary.io/#reference/authentication/create-an-access-token
    #
    module Authentication
      private

      # Returns the hash response from ClientSuccess
      # containing the 'access-token' key.
      #
      # @param [String] username
      # @param [String] password
      # @return [Hash]
      #
      def request_access_token(username, password)
        resp = auth_connection.post(
          build_api_endpoint_for('/auth'),
          username: username,
          password: password
        )
        process_response(resp)
      end

      # A custom connection for the auth endpoint, since it
      # uses a different content type header.
      #
      def auth_connection
        Faraday.new(url: api_url) do |conn|
          conn.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          apply_default_connection_opts_to(conn)
        end
      end
    end
  end
end
