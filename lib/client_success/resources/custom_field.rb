module ClientSuccess
  module Resources
    # Resource representing a Client Success 'CustomField'.
    #
    # Can be retrieved using the contact custom fields API
    # endpoint. There is currently no endpoint to create
    # them.
    #
    class CustomField < Base
      declare_read_only_attrs id: :int
      declare_attrs resource_id: :int,
                    name: :string,
                    label: :string,
                    type_id: :int,
                    type: :string,
                    sequence: :int,
                    auto_sync: :boolean
    end
  end
end
