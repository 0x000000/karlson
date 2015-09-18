require 'erb'

require 'karlson/version'

require 'karlson/validation/validators/presence_validators'
require 'karlson/validation/validators/types_validators'
require 'karlson/validation/validators/uniqueness_validators'
require 'karlson/validation/validator'

require 'karlson/readers/empty_object'
require 'karlson/readers/types_registry'
require 'karlson/readers/enum_reader'
require 'karlson/readers/pack_reader'

module Karlson
end