module Karlson
  module Validator
    def self.validate_presence(variable, variable_name, type_info)
      error(variable_name, :should_present, type_info) if variable.nil?
    end
  end
end