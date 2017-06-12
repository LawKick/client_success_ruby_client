module ClientSuccess
  module UsageApi
    # The wrapper for Client Success Usage API.
    #
    class Client < ClientSuccess::BaseClient
      DEFAULT_OPTS = { api_version: '1.0.0' }.freeze
      API_DOMAIN = 'https://usage.clientsuccess.com'.freeze
      REQUIRED_FIELDS = %i(project_id api_key api_version).freeze

      attr_reader(*REQUIRED_FIELDS)

      # @param [String] project_id
      # @param [String] api_key
      # @option [String] api_version
      #   Defaults to '1.0.0'
      #
      def initialize(opts = {})
        opts = DEFAULT_OPTS.merge(opts)
        validate(opts)
        @project_id = opts[:project_id]
        @api_key = opts[:api_key]
        @api_version = opts[:api_version]
      end

      # The single API point. See:
      # http://docs.clientsuccessusage.apiary.io/#introduction/events-api
      #
      # ClientSuccess' documentation is unclear, but it appears that the
      # 'identity' properties 'organization' and 'user' refer to a Client
      # and a Contact, respectively.
      #
      # @param [String] id
      #   The event id that you want to track. It appears from the
      #   the documentation that these are dynamically created.
      # @param [ClientSuccess::Resources::Client] org
      # @param [ClientSuccess::Resources::Contact] user
      # @option [Integer] value
      #   Change if you wish to signify multiple events of
      #   this kind.
      # @return [Boolean]
      #
      def add_event(id, org:, user:, value: 1)
        params = create_payload(org, user, value)
        resp = connection.post do |req|
          req.url build_api_endpoint(id)
          req.headers['Content-Type'] = CONTENT_TYPE
          req.body = JSON.generate(params)
        end
        process_response(resp)['created'] # Should be true/false
      rescue Errors::UnprocessableEntity
        false
      end

      private

      def build_api_endpoint(event_id)
        "#{API_DOMAIN}/collector/#{api_version}/" \
        "projects/#{project_id}/" \
        "events/#{event_id}" \
        "?api_key=#{api_key}"
      end

      def connection
        @connection ||= Faraday.new do |conn|
          apply_default_connection_opts_to(conn)
        end
      end

      def validate(opts)
        opts.values_at(*REQUIRED_FIELDS).each do |value|
          raise ArgumentError unless value
        end
      end

      def create_payload(org, user, value)
        {
          identity: {
            organization: organization_payload(org),
            user: user_payload(user)
          },
          value: value
        }
      end

      def organization_payload(org)
        {
          id: org.id,
          name: org.name
        }
      end

      def user_payload(user)
        {
          id: user.id,
          name: "#{user.first_name} #{user.last_name}",
          email: user.email
        }
      end
    end
  end
end
