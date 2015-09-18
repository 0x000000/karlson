module Karlson
  module Readers
    module TypesRegistry
      INTERNAL_TYPES         = [:string, :boolean, :number].freeze
      RUBY_TO_INTERNAL_TYPES = Hash[INTERNAL_TYPES.map { |t| [t, t] }].freeze

      @user_types             = []
      @enums, @packs          = {}, {}
      @internal_types_mapping = {}.merge(RUBY_TO_INTERNAL_TYPES)

      class << self
        def register(builder)
          type_info = builder.type_info

          type_name = type_info[:name]
          @user_types << type_name

          @internal_types_mapping[type_name] = type_info[:type]

          case type_info[:type]
          when :enum
            @enums[type_name] = builder
          when :pack
            @packs[type_name] = builder
          else
            raise ArgumentError, "Unknown type: #{type_info[:type]}"
          end
        end

        def internal_types_mapping
          @internal_types_mapping
        end

        def user_types
          @user_types
        end

        def all_types
          INTERNAL_TYPES + @user_types
        end

        def enum(type_name)
          @enums[type_name]
        end

        def pack(type_name)
          @packs[type_name]
        end

        def enums
          @enums.values
        end

        def packs
          @packs.values
        end

        def clear
          [@user_types, @internal_types_mapping, @enums, @packs].each(&:clear)
          @internal_types_mapping = {}.merge(RUBY_TO_INTERNAL_TYPES)
        end

        def compute_all
          (@enums.values + @packs.values).each(&:compute)
        end
      end
    end
  end
end
