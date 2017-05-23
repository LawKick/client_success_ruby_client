module ClientSuccess
  module Resources
    # Resource representing a Client Success 'Contact'.
    #
    # See:
    # http://docs.clientsuccessapi.apiary.io/#reference/contacts/contact-by-external-client-id/get-contact-details-by-client-external-id-and-email-address
    #
    class Contact < Base
      declare_read_only_attrs id: :int
      declare_attrs client_id: :int,
                    name: :string,
                    email: :string,
                    phone: :string,
                    mobile: :string,
                    title: :string,
                    preferred_name: :string,
                    linkedin_url: :string,
                    photo_url: :string,
                    first_name: :string,
                    last_name: :string,
                    tenant_id: :int,
                    note: :string,
                    executive_sponsor: :boolean,
                    advocate: :boolean,
                    champion: :boolean,
                    custom_field_values: [CustomFieldValue]
    end
  end
end
