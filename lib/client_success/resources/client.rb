module ClientSuccess
  module Resources
    # Resource representing a Client Success 'Client'.
    #
    # See:
    # http://docs.clientsuccessapi.apiary.io/#reference/clients/
    #
    class Client < Base
      declare_read_only_attrs id: :int
      declare_attrs external_id: :string,
                    name: :string,
                    site_url: :string,
                    client_segment_id: :int,
                    zip: :string,
                    modified_by_employee_id: :int,
                    status_id: :int,
                    inception_date: :datetime,
                    created_by_employee_id: :int,
                    tenant_id: :int,
                    linkedin_url: :string,
                    managed_by_employee_id: :int,
                    active: :boolean,
                    success_score: :int,
                    active_client_success_cycle_id: :int,
                    crm_customer_id: :int,
                    crm_customer_url: :string,
                    zendesk_id: :int,
                    desk_id: :int,
                    freshdesk_id: :int,
                    user_voice_id: :int,
                    assigned_sales_rep: :string,
                    key_contact_id: :int,
                    street: :string,
                    city: :string,
                    state: :string,
                    country: :string,
                    timezone: :string,
                    custom_field_values: [CustomFieldValue]
    end
  end
end
