module ClientSuccess
  module Api
    # Module containing the available methods to access
    # Contact objects from ClientSuccess.
    #
    module Contacts
      CONTACT_API_PATH = '/contacts'.freeze

      # GET /v1/clients/:client_id/contacts
      #
      # Retrieves all contacts for a particular client. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/contacts/contacts-collection/list-all-contacts-of-a-client
      #
      # @param [Resources::Client or Integer]
      # @return [Array<Resources::Contact>]
      #
      def all_contacts_for(id_able)
        id = id_able.is_a?(Resources::Client) ? id_able.id : id_able
        resp = get contact_path_for(client_id: id)
        result = process_response(resp)
        result.each.map { |c| Resources::Contact.new(c) }
      end

      # POST /v1/clients/:client_id/contacts
      #
      # Creates a new contact for a particular client.
      #
      # @param [Resources::Contact] contact
      # @option [Resources::Client or Integer or String] for_client
      #   Can be left blank if contact param has a client_id attribute.
      # @return [Boolean]
      #
      def create_contact(contact, for_client: nil)
        raise ArgumentError, 'Cannot create contact with id' if contact.id
        client_id = resolve_client_id_from(for_client, contact)
        raise ArgumentError, 'Must specify client id' if client_id.nil?
        resp = post contact_path_for(client_id: client_id),
                    params: contact.as_json
        process_response(resp)
        contact.id = extract_id_from_location_path(resp.headers['Location'])
        true
      rescue Errors::UnprocessableEntity
        false
      end

      # GET /v1/clients/:client_id/contacts/:contact_id
      #
      # Gets summary for a contact. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/contacts/contact/get-a-contact-summary
      #
      # @param [Integer or String] id
      # @param [Integer or Resources::Client] for_client
      # @return [Resources::Contact or NilClass]
      #
      def contact_from_id(id, for_client:)
        client_id = if for_client.is_a?(Resources::Client)
                      for_client.id
                    else
                      for_client
                    end
        resp = get contact_path_for(client_id: client_id, contact_id: id)
        result = process_response(resp)
        Resources::Contact.new(result)
      rescue Errors::NotFound
        nil
      end

      # DELETE /v1/clients/:client_id/contacts/:contact_id
      #
      # Destroys a contact. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/contacts/contact/delete-a-contact
      #
      # @param [Integer, String, or Resources::Contact] contact
      # @option [Integer, String, or Resources::Client] for_client
      #   Must only be specified if passed Contact does not have
      #   a client_id attribute.
      #
      def delete_contact(id_able, for_client: nil)
        contact_id = resolve_contact_id_from(id_able)
        client_id = resolve_client_id_from(for_client, id_able)
        if contact_id.nil? || client_id.nil?
          raise ArgumentError, 'Must specify contact and client id'
        end
        resp = delete contact_path_for(client_id: client_id,
                                       contact_id: contact_id)
        process_response(resp)
        true
      rescue Errors::Conflict
        false
      end

      # GET /v1/contacts?clientExternalId=xxxx&email=yyyy
      #
      # Retrieves a contact matching a Client's external id and
      # email address. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/contacts/contact-by-external-client-id/get-contact-details-by-client-external-id-and-email-address
      #
      # @param [String] external_client_id
      # @param [String] email
      # @return [Resources::Contact or NilClass]
      #
      def contact_from(external_client_id:, email:)
        resp = get CONTACT_API_PATH,
                   params: { externalClientId: external_client_id,
                             email: email }
        result = process_response(resp)
        Resources::Contact.new(result)
      rescue Errors::NotFound
        nil
      end

      # GET /v1/clients/:client_id/contacts/:contact_id/details
      #
      # Gets details for a contact. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/contacts/contact-details/get-a-contact-details
      #
      # @param [Integer or String]
      # @param [Integer or Resources::Client]
      # @return [Resources::Contact or NilClass]
      #
      def contact_details_from_id(id, for_client:)
        client_id = if for_client.is_a?(Resources::Client)
                      for_client.id
                    else
                      for_client
                    end
        resp = get "#{contact_path_for(client_id: client_id, contact_id: id)}" \
                   '/details'
        result = process_response(resp)
        Resources::Contact.new(result)
      rescue Errors::NotFound
        nil
      end

      # PUT /v1/clients/:client_id/contacts/:contact_id/details
      #
      # Updates details for a contact. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/contacts/contact-details/update-a-contact-detail
      #
      # @param [Resources::Contact] contact
      # @param [Resources::Client or String] for_client
      # @return [Boolean]
      #
      def update_contact_details(contact, for_client: nil)
        client_id = resolve_client_id_from(for_client, contact)
        raise ArgumentError, 'Must specify client id' if client_id.nil?
        path = contact_path_for(client_id: client_id, contact_id: contact.id)
        resp = put "#{path}/details", params: contact.as_json
        process_response(resp)
        true
      rescue Errors::UnprocessableEntity
        false
      end

      # POST /v1/clients/:client_id/contacts/:contact_id/details
      #
      # Creates a contact with details. See:
      # http://docs.clientsuccessapi.apiary.io/#reference/contacts/contact-details/create-new-contact-with-details
      #
      # @param [Resources::Contact] contact
      # @param [Resources::Client or String] for_client
      # @return [Boolean]
      #
      def create_detailed_contact(contact, for_client: nil)
        raise ArgumentError, 'Cannot create contact with id' if contact.id
        client_id = resolve_client_id_from(for_client, contact)
        raise ArgumentError, 'Must specify client id' if client_id.nil?
        resp = post "#{contact_path_for(client_id: client_id)}/details",
                    params: contact.as_json
        process_response(resp)
        contact.id = extract_id_from_location_path(resp.headers['Location'])
        true
      rescue Errors::UnprocessableEntity
        false
      end

      # GET /v1/contact-custom-fields
      #
      # Retrieves all available custom fields for Client Success
      # contacts.
      #
      # @return [Array<Resources::CustomField>]
      #
      def contact_custom_fields
        resp = get '/contact-custom-fields'
        result = process_response(resp)
        if result.is_a?(Array)
          result.map { |i| Resources::CustomField.new(i) }
        else
          []
        end
      end

      private

      # Generates a path for a contact. Most Contact paths
      # are nested under a Client. However, some are top level.
      # Returns the appropriate path configuration based on
      # what is passed, since top-level path is only used
      # when there is a contact id.
      #
      # @option [Integer or String] client_id
      # @option [Integer or String] contact_id
      # @return [String]
      #
      def contact_path_for(client_id: nil, contact_id: nil)
        path = if client_id
                 "#{Clients::CLIENT_API_PATH}/#{client_id}#{CONTACT_API_PATH}"
               else
                 CONTACT_API_PATH
               end
        path += "/#{contact_id}" if contact_id
        path
      end

      def resolve_contact_id_from(id_able)
        return id_able unless id_able.is_a?(Resources::Contact)
        id_able.id
      end

      def resolve_client_id_from(client_id_able, contact)
        if client_id_able && client_id_able.is_a?(Resources::Client)
          client_id_able.id
        elsif client_id_able
          client_id_able
        else
          contact.client_id
        end
      end
    end
  end
end
