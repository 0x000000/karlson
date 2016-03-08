module Utils
  module File
    def self.fetch_lang_names_by(class_name)
      names                = class_name.split('::')
      lang_name, file_name = Utils::Text.underscore_case(names[-2]), Utils::Text.underscore_case(names[-1])

      [lang_name, file_name]
    end
  end
end
