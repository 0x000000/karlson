require 'erb'
require 'fileutils'

require 'karlson/version'

require 'karlson/utils/text'
require 'karlson/utils/file'

require 'karlson/validation/validators/presence_validators'
require 'karlson/validation/validators/types_validators'
require 'karlson/validation/validators/uniqueness_validators'
require 'karlson/validation/validator'

require 'karlson/readers/empty_object'
require 'karlson/readers/types_registry'
require 'karlson/readers/enum_reader'
require 'karlson/readers/pack_reader'

require 'karlson/writers/langs_registry'
require 'karlson/writers/base_render'
require 'karlson/writers/base_writer'

require 'karlson/writers/javascript/enum'
require 'karlson/writers/javascript/pack'
require 'karlson/writers/javascript/metadata'
require 'karlson/writers/javascript/writer'

require 'karlson/dsl'
