module Karlson
  module Validator
    def self.validate_being_safe_symbol(variable, variable_name, type_info)
      error(variable_name, :should_be_symbol, type_info) unless variable.kind_of? Symbol
      error(variable_name, :should_contain_safe_chars, type_info) unless variable =~ /^[a-z0-9_]+\z/i
      error(variable_name, :should_not_start_with_nums, type_info) if variable =~ /^[0-9]+/i
    end

    def self.validate_being_not_reserved_keyword(variable, variable_name, type_info)
      error(variable_name, :should_not_be_reserved_word, type_info) if Readers::TypesRegistry::INTERNAL_TYPES.include?(variable)
    end

    def self.validate_being_positive_number(variable, variable_name, type_info)
      error(variable_name, :should_be_number, type_info) unless variable.kind_of? Integer
      error(variable_name, :should_be_positive_number, type_info) if variable < 0
      error(variable_name, :should_be_lesser_then_short, type_info) if variable > 32_767
    end

    def self.validate_being_true_type(variable, variable_name, type_info)
      case variable
      when Array # List<Type>
        if variable.length == 1
          Validator.validate variable[0],
                             {:as => 'List type', :for => [:presence, :being_safe_symbol, :being_true_type]},
                             type_info
        else
          error(variable_name, :should_be_proper_type, type_info)
        end

      when Hash # Map<Type1,Type2>
        if variable.keys.length == 1
          key, value = variable.keys.first, variable.values.first

          Validator.validate key,
                             {:as => 'Map key type', :for => [:presence, :being_safe_symbol, :being_true_type]},
                             type_info

          error('', :only_systypes_as_key, type_info) unless Readers::TypesRegistry::INTERNAL_TYPES.include?(key)

          Validator.validate value,
                             {:as => 'Map value type', :for => [:presence, :being_true_type]},
                             type_info

        else
          error(variable_name, :should_be_proper_type, type_info)
        end


      when Symbol
        error(variable, :type_not_defined, type_info) unless Readers::TypesRegistry.all_types.include?(variable)
      else
        error(variable_name, :should_be_proper_type, type_info)
      end
    end

    def self.validate_valid_field_options_format(arguments, variable_name, type_info)
      options, type, internal_type = arguments

      _check_required_options(options[:required], variable_name, type_info)
      _check_default_options(options[:default], internal_type, variable_name, type_info)
    end

    def self._check_default_options(default, internal_type, variable_name, type_info)
      return if default.nil?

      caption = " default: for :#{internal_type} type"

      case internal_type
      when :string
        error(variable_name + caption, :should_be_string_or_nil, type_info) unless default.is_a? String
      when :number
        error(variable_name + caption, :should_be_number_or_nil, type_info) unless default.is_a? Integer
      when :boolean
        error(variable_name + caption, :should_be_bool_or_nil, type_info) unless [false, true].include?(default)
      when :enum
        error(variable_name + caption, :should_be_number_or_nil, type_info) unless default.is_a? Integer
      else
        error(variable_name + caption, :not_implemented, type_info)
      end
    end

    def self._check_required_options(required_option, variable_name, type_info)
      return if required_option.nil?

      error(variable_name + " :required", :should_be_boolean, type_info) unless [false, true].include?(required_option)
    end
  end
end
