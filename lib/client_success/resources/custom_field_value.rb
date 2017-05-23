module ClientSuccess
  module Resources
    # Resource representing a Client Success 'CustomFieldValue'.
    #
    # Has no API point of its own. Nested under Client or Contact
    # resources. See, e.g.,:
    # http://docs.clientsuccessapi.apiary.io/#reference/clients/
    #
    class CustomFieldValue < Base
      declare_read_only_attrs id: :int
      declare_attrs contact_id: :int,
                    field_id: :int,
                    value_id: :int,
                    name: :string,
                    value: :string,
                    label: :string,
                    auto_sync: :boolean,
                    type: :string,
                    sequence: :int,
                    push: :boolean,
                    pull: :boolean
    end
  end
end
