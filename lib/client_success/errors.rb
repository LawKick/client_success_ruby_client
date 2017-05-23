module ClientSuccess
  module Errors
    # Basic error to allow user to rsecue from all ClientSuccess
    # errors.
    #
    class Base < StandardError; end

    # 400 error.
    #
    class BadRequest < Base; end

    # 401 error.
    #
    class Unauthorized < Base; end

    # 402 error.
    #
    class PaymentRequired < Base; end

    # 403 error.
    #
    class Forbidden < Base; end

    # 404 error.
    #
    class NotFound < Base; end

    # 405 error.
    #
    class MethodNotAllowed < Base; end

    # 409 error.
    #
    class Conflict < Base; end

    # 422 error.
    #
    class UnprocessableEntity < Base; end

    # 500 error.
    #
    class InternalServerError < Base; end

    # 502 error.
    #
    class BadGateway < Base; end

    # 503 error (e.g., maintenance)
    #
    class ServiceUnavailable < Base; end

    # A general class for all other errors.
    #
    class Unknown < Base; end
  end
end
