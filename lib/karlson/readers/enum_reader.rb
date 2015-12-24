module Karlson
  module Readers
    class EnumReader
      attr_accessor :type_info

      def initialize(name, &block)
        @type_info = {
          type:             :enum,
          name:             nil,
          fields_names:     [],
          fields_positions: [],
          fields:           {}
        }

        validate name, as: 'Enum name', for: [:presence, :being_safe_symbol, :type_name_uniqueness]

        @type_info[:name] = name
        @block            = block
      end

      def compute
        empty_obj = EmptyObject.new
        empty_obj.instance_eval &@block
        empty_obj.instance_eval { @fields }.each do |method_name, args|
          register method_name, args[0]
        end
      end

      private
      
      def validate(variable, options)
        ::Karlson::Validator.validate variable, options, @type_info.dup
      end

      def register(name=nil, position=nil)
        validate position, as: 'Field position', for: [:presence, :being_positive_number, :field_position_uniqueness]
        validate name, as: 'Field name', for: [:field_name_uniqueness]

        @type_info[:fields_names] << name
        @type_info[:fields_positions] << position

        @type_info[:fields][position] = {name: name}
      end
    end
  end
end
