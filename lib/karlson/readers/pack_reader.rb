module Karlson
  module Readers
    class PackReader < BasicObject
      attr_accessor :type_info

      def initialize(name, &block)
        @type_info = {
          type:             :pack,
          name:             nil,
          fields_types:     [],
          fields_names:     [],
          fields_positions: [],
          fields_options:   [],
          fields:           {}
        }

        validate name, as: 'Pack name', for: [:presence, :being_safe_symbol, :type_name_uniqueness]

        @type_info[:name] = name
        @block            = block
      end

      def compute
        empty_obj = EmptyObject.new
        empty_obj.instance_eval &@block
        empty_obj.instance_eval { @fields }.each do |method_name, args|
          register method_name, args[0], args[1], args[2]
        end
      end

      private

      def validate(variable, options)
        ::Karlson::Validator.validate variable, options, @type_info.dup
      end

      def register(name = nil, position = nil, type = nil, options)
        validate name, as: 'Field name', for: [:presence, :being_safe_symbol, :field_name_uniqueness]
        validate position, as: 'Field position', for: [:presence, :being_positive_number, :field_position_uniqueness]
        validate type, as: 'Field type', for: [:presence, :being_true_type]

        internal_type = convert_to_internal(type)

        options = {default: nil, required: false}.merge(options || {})
        validate [options, type, internal_type], as: 'Field options', for: [:valid_field_options_format]

        @type_info[:fields_types] << type
        @type_info[:fields_names] << name
        @type_info[:fields_positions] << position

        @type_info[:fields][position] = options.merge({name: name, type: type, internal_type: internal_type})
      end

      def convert_to_internal(type)
        if type.is_a? ::Array
          :list
        elsif type.is_a? ::Hash
          :map
        else
          TypesRegistry.internal_types_mapping[type]
        end
      end
    end
  end
end
