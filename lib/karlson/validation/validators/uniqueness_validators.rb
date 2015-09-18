module Karlson
  module Validator
    def self.validate_field_position_uniqueness(variable, variable_name, type_info)
      if type_info[:fields_positions].include? variable.to_i
        error(variable_name + " with number #{variable}", :already_defined_here, type_info)
      end
    end

    def self.validate_field_name_uniqueness(variable, variable_name, type_info)
      if type_info[:fields_names].include? variable
        error(variable_name + " with name :#{variable}", :already_defined_here, type_info)
      end
    end

    def self.validate_type_name_uniqueness(variable, variable_name, type_info)
      error(variable_name, :should_be_uniq, type_info) if Readers::TypesRegistry.user_types.include?(variable)
      error(variable_name, :should_not_be_reserved_word, type_info) if Readers::TypesRegistry::INTERNAL_TYPES.include?(variable)
    end
  end
end
