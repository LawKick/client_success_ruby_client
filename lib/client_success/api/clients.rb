module ClientSuccess
  module Api
    # Module containing the available methods to access
    # Client objects from ClientSuccess.
    #
    module Clients
      CLIENT_API_PATH = '/clients'.freeze
      CUSTOM_FIELD_UPDATE_PATH = '/customfield/value/client'.freeze

      # GET /v1/clients
      #
      # Retrieves all Clients. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/clients/clients-collection/list-all-clients
      #
      # Does not yet support params for assignedCsmId and activeOnly.
      #
      def all_clients
        resp = get CLIENT_API_PATH
        result = process_response(resp)
        return [] if result.empty? # In case response is {}
        result.each.map { |c| Resources::Client.new(c) }
      end

      # POST /v1/clients
      #
      # Creates a new client. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/clients/clients-collection/create-a-new-client
      #
      # @param [Resources::Client] client
      # @return [Boolean]
      #   Returns true if successful.
      #
      def create_client(client)
        resp = post CLIENT_API_PATH, params: client.as_json
        process_response(resp)
        client.id = extract_id_from_location_path(resp.headers['Location'])
        true
      rescue Errors::UnprocessableEntity
        false
      end

      # GET /v1/clients?externalId=<external_id>
      #
      # Gets details for a client based on the client's
      # external id. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/clients/client/get-client-details-by-external-id
      #
      # @param [Integer or String] ext_id
      # @return [Resources::Client or NilClass]
      #
      def client_from_external_id(ext_id)
        resp = get CLIENT_API_PATH, params: { 'externalId' => ext_id }
        result = process_response(resp)
        Resources::Client.new(result)
      rescue Errors::NotFound
        nil
      end

      # GET /v1/clients/:client_id
      #
      # Gets details for a client. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/clients/client/get-a-client-detail
      #
      # @param [Integer or String] id
      # @return [Resources::Client or NilClass]
      #
      def client_from_id(id)
        resp = get "#{CLIENT_API_PATH}/#{id}"
        result = process_response(resp)
        Resources::Client.new(result)
      rescue Errors::NotFound
        nil
      end

      # PUT /v1/clients/:client_id
      #
      # Updates the details for a client. Appears that
      # all attributes for a client must be provided.
      # See:
      # http://docs.clientsuccessapi.apiary.io/#reference/clients/client/update-a-client-detail
      #
      # @param [Resources::Client]
      #   Client must have 'id' attribute.
      # @return [Boolean]
      #
      def update_client(client)
        raise ArgumentError, 'Cannot update without id' if client.id.nil?
        resp = put "#{CLIENT_API_PATH}/#{client.id}", params: client.as_json
        process_response(resp)
        true
      rescue Errors::UnprocessableEntity
        false
      end

      # PATCH /v1/customfield/value/client/:client_id
      #
      # Updates a single custom field for a client.
      # NOTE: It is not clear, but this species of custom fields
      # appear to be different than the typical resource custom
      # field, which applies to the Contact resource.
      #
      # @param [Resources::Client] client
      # @param [String] cf_hash
      #   A JSON hash of the custom field, e.g.:
      #   { 'My Custom Field': 'foo' }
      # @return [Boolean]
      #
      def update_client_custom_field(client, cf_hash)
        raise ArgumentError, 'Cannot update without id' if client.id.nil?
        resp = patch "#{CUSTOM_FIELD_UPDATE_PATH}/#{client.id}",
                     params: cf_hash
        process_response(resp)
        true
      rescue Errors::UnprocessableEntity
        false
      end

      # DELETE /v1/clients/:client_id
      #
      # Destroys a client. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/clients/client/delete-a-client
      #
      # @param [Resrouces::Client, Integer or String] id
      # @return [Boolean]
      #
      def delete_client(id_able)
        id = id_able.is_a?(Resources::Client) ? id_able.id : id_able
        raise ArgumentError, 'Must pass id' if id.nil?
        resp = delete "#{CLIENT_API_PATH}/#{id}"
        process_response(resp)
        true
      rescue Errors::Conflict
        false
      end
    end
  end
end
