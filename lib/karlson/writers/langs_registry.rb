module Karlson
  module Writers
    module LangsRegistry
      @requested_langs = {}
      @available_langs = {}

      class << self
        def request_compilation(language, options)
          #todo: validate me
          @requested_langs[language] = options
        end

        def register_language(language, writer_class)
          @available_langs[language] = writer_class.new
        end

        def write_all
          p @available_langs
        end
      end
    end
  end
end
