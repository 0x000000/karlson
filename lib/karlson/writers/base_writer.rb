module Karlson
  module Writers
    class BaseWriter
      def self.inherited(lang_writer)
        lang_name = lang_writer.name.split('::')[-2].downcase.to_sym
        Karlson::Writers::LangsRegistry.register_language(lang_name, lang_writer)
      end
    end
  end
end
