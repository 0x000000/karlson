module Karlson
  module Validator
    ERROR_EXPLANATION = {
      should_present:              'should be presented!',
      should_be_symbol:            'should be a symbol!',
      should_contain_safe_chars:   'should contain only [a-z], [0-9] and _ chars!',
      should_not_start_with_nums:  'should not start with numbers!',
      should_be_number:            'should be an integer number!',
      should_be_boolean:           'should be a boolean value!',
      should_be_positive_number:   'should be a positive number or 0!',
      should_be_string_or_nil:     'should be a string or nil',
      should_be_json_string_or_nil:'should be a valid JSON string or nil',
      should_be_bool_or_nil:       'should be a boolean or nil',
      should_be_number_or_nil:     'should be a number or nil',
      should_be_lesser_then_short: 'should be lesser than 32767!',
      already_defined_here:        'already defined here!',
      should_be_uniq:              'should be uniq!',
      should_not_be_reserved_word: 'should not be one of reserved words!',
      should_be_proper_type:       'should be a symbol, list or map!',
      type_not_defined:            'type not defined!',
      only_systypes_as_key:        'only system types allowed as map keys!',
      not_implemented:             'is not implemented yet',
    }

    def self.validate(variable, options, type_info) #todo: change signature to variable, details, options
      variable_name = options[:as]
      validators    = options[:for]

      validators.each do |validator_name|
        send "validate_#{validator_name}", variable, variable_name, type_info
      end
    end

    private

    def self.error(who, why, type_info)
      raise "#{who} #{ERROR_EXPLANATION[why]}"
    end
  end
end
