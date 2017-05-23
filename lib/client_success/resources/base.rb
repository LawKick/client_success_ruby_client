module ClientSuccess
  module Resources
    class ReadOnlyAttribute < StandardError; end
    class InvalidResourceType < StandardError; end
    # Base class for all Client Success resources.
    #
    # Resources are initialized using a Hash (typically
    # a response from the API). The resource is not opinionated
    # as to the attributes of any given resource, and, using
    # 'method_missing' override, will assume that any returned
    # key is a valid attribute on that resource.
    #
    # If any value is an Array or Hash, it will check if a
    # Resource class exists using a class name corresponding to
    # the key name. E.g., the Hash
    #   { foos: [...] }
    # will have this class check if a ClientSuccess::Resources::Foo
    # class exists. If so, each instance will be instantiated with
    # that class; if not, the value will be left raw.
    #
    class Base
      include JsonUtilities

      RESOURCE_ATTR_TYPES = %i(int string datetime boolean).freeze

      class << self
        attr_reader :attributes

        # Allows subclass resources to define the available
        # attributes, so that there are corresponding getter
        # and setter methods available.
        #
        # @param [Hash] attrs
        #
        # @example
        #   class Foo < Base
        #     declare_attrs(bar: :int, zoo: :string)
        #     ...
        #   end
        #
        def declare_attrs(attrs)
          # Stored attributes for type conversion on save.
          validate_types_for(attrs)
          @attributes = (@attributes || {}).merge(attrs)
          attrs.each_pair do |attr_name, _value_type|
            define_read_method(attr_name)
            define_write_method(attr_name)
          end
        end

        # Allows subclass resources to define available read-only
        # attributes (e.g., 'id'), so that there is a corresponding
        # getter method available, and the setter method will raise
        # an error.
        #
        # @param [Hash] attrs
        #
        # @example
        #   class Foo < Base
        #     declare_read_only_attrs(id: :int)
        #     ...
        #   end
        #
        def declare_read_only_attrs(attrs)
          @attributes = (@attributes || {}).merge(attrs)
          attrs.each_pair do |attr_name, _value_type|
            define_read_method(attr_name)
            define_write_error_method(attr_name)
          end
        end

        # @param [Hash] attrs
        #
        def validate_types_for(attrs)
          attrs.each_pair do |k, v|
            next if valid_type?(v)
            raise InvalidResourceType,
                  "Declared type '#{v}' for attribute '#{k}' is invalid"
          end
        end

        def valid_type?(t)
          RESOURCE_ATTR_TYPES.include?(t) ||
            t.is_a?(Class) ||
            (t.is_a?(Array) && !t.first.is_a?(Array) && valid_type?(t.first))
        end

        def define_read_method(attr_name)
          define_method attr_name do
            data[attr_name.to_s]
          end
        end

        def define_write_method(attr_name)
          define_method "#{attr_name}=" do |value|
            data[attr_name.to_s] = value
          end
        end

        def define_write_error_method(attr_name)
          define_method "#{attr_name}=" do |value|
            if send attr_name
              raise ReadOnlyAttribute,
                    "Attribute '#{attr_name}' " \
                    'cannot be modified once assigned'
            end
            data[attr_name.to_s] = value
          end
        end
      end

      attr_reader :raw_data, :data

      # @param [Hash] hash
      #
      # @return [ClientSuccess::Resources::Base]
      #
      def initialize(hash = {})
        @raw_data = hash
        @data = process_hash_resource
      end

      def as_json
        data.inject({}) do |obj, (k, v)|
          t_key = camel_case_for(k.to_s)
          obj[t_key] = if v.is_a? Array
                        v.map { |i| i.respond_to?(:as_json) ? i.as_json : i }
                       else
                         v.respond_to?(:as_json) ? v.as_json : v
                       end
          obj
        end
      end

      private

      # Processes the ClientSuccess hash by underscoring all keys and
      # creating new resources for any keys that map to a
      # ClientSuccess::Resources object.
      #
      def process_hash_resource
        raw_data.inject({}) do |obj, (k, v)|
          t_key = underscore_for(k.to_s) # Transform key to underscore
          obj[t_key] = if resourceable?(t_key)
                         create_resource(self.class.attributes[t_key.to_sym], v)
                       else
                         v
                       end
          obj
        end
      end

      # Whether the value is a candidate to be a
      # ClientSuccess::Resources object or a collection
      # of objects. Set forth by declaring an attribute
      # with an Array or a Class.
      #
      # See comment to the 'declare_attrs' method.
      #
      # @param [Object] value
      # @return [Boolean]
      #
      def resourceable?(key)
        value_type = self.class.attributes[key.to_sym]
        value_type.is_a?(Array) || value_type.is_a?(Class)
      end

      # Process a value into a ClientSuccess::Resources object
      # or an Array of objects.
      #
      # @param [klass_name] String
      # @param [Hash or Array] value
      # @return [Array or ClientSuccess::Resources::Base]
      #
      def create_resource(res_type, value)
        if res_type.is_a?(Array)
          invalid_attribute_value(Array, value) unless value.is_a?(Array)
          value.map { |item| instantiate_object_for(res_type.first, item) }
        else
          instantiate_object_for(res_type, value)
        end
      end

      # Returns an object based on the passed 'klass' value,
      # which is obtained from the Resource's 'declared_attrs'.
      #
      # If it is a symbol (e.g., :int, :boolean, etc.), just return
      # the value. Otherwise, a specific class was specified, so
      # instantiate that.
      #
      # @param [Symbol or Class] klass
      # @param [Object] value
      #
      def instantiate_object_for(klass, value)
        return value unless klass.is_a?(Class)
        klass.new(value)
      end

      # Accessor for the data attribute, using Ruby-preferred
      # snake case.
      #
      # @param [String or Symbol] snake_key
      # @return [Object]
      #
      # def data_by_snake_case(snake_key)
      #   data[camel_case_for(snake_key)]
      # end

      def invalid_attribute_value(klass, value)
        raise ArgumentError,
              "Declared attribute was #{klass}, received #{value}"
      end
    end
  end
end
