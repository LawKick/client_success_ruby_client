require 'faraday'
require 'client_success/api'

module ClientSuccess
  # The API wrapper for Client Success.
  #
  class ApiClient
    include Api::Authentication,
            Api::Clients,
            Api::Contacts

    API = { domain: 'https://api.clientsuccess.com',
            version: '1' }.freeze
    REQUIRED_INIT_PARAMS = %i(email password).freeze
    CONTENT_TYPE = 'application/json'.freeze
    ERRORS = { 400 => Errors::BadRequest,
               401 => Errors::Unauthorized,
               402 => Errors::PaymentRequired,
               403 => Errors::Forbidden,
               404 => Errors::NotFound,
               405 => Errors::MethodNotAllowed,
               409 => Errors::Conflict,
               422 => Errors::UnprocessableEntity,
               500 => Errors::InternalServerError,
               502 => Errors::BadGateway,
               503 => Errors::ServiceUnavailable }.freeze

    attr_reader :email, :password

    # @param [String] email
    # @param [String] password
    # @option [String] url
    #   Override the default API url. Useful for
    #   testing against a mock server.
    #
    def initialize(opts = {})
      validate_init_opts(opts)
      @email = opts[:email]
      @password = opts[:password]
      @api_url = opts[:url]
    end

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

    def delete(path)
      connection.delete do |req|
        req.url build_api_endpoint_for(path)
      end
    end

    def api_url
      @api_url || API[:domain]
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
      @connection ||= Faraday.new(url: API[:domain]) do |conn|
        # conn.token_auth(access_token)
        conn.headers['Authorization'] = access_token
        apply_default_connection_opts_to(conn)
      end
    end

    def validate_response(resp)
      return if resp.status < 400
      error_class = ERRORS[resp.status] || ClientSuccess::Errors::Unknown
      raise error_class, error_message(resp)
    end

    def error_message(response)
      "Server responded with code #{response.status}\n" \
      "Request URI: #{response.to_hash[:url]}\n" \
      "Message: #{response.body}"
    end

    def parse_response(resp)
      if resp['content-type'] == 'application/pdf'
        resp.body
      elsif resp.body.strip.empty?
        {}
      else
        JSON.parse(resp.body.strip)
      end
    end

    def build_api_endpoint_for(path)
      "/v#{API[:version]}#{path}"
    end

    def access_token
      @access_token ||= request_access_token(email, password)['access_token']
    end

    # @param [Faraday::Connection] connection
    #
    def apply_default_connection_opts_to(connection)
      connection.request :url_encoded
      connection.adapter Faraday.default_adapter
    end

    def process_response(resp)
      validate_response(resp)
      parse_response(resp)
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
