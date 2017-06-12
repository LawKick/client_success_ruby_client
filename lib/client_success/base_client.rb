require 'client_success/errors'

module ClientSuccess
  class BaseClient
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

    protected

    # @param [Faraday::Connection] connection
    #
    def apply_default_connection_opts_to(connection)
      connection.request :url_encoded
      connection.adapter Faraday.default_adapter
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
        begin
          JSON.parse(resp.body.strip)
        rescue JSON::ParserError
          # Client success can return non-JSON
          # responses, like 'Update successful.'
          ''
        end
      end
    end

    def process_response(resp)
      validate_response(resp)
      parse_response(resp)
    end
  end
end
