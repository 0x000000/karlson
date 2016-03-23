module Karlson
  module Writers
    module LangsRegistry
      DEFAULT_OPTIONS = {working_dir: nil}

      @requested_langs, @available_langs, @template_langs = {}, {}, {}

      class << self
        attr_reader :available_langs, :requested_langs, :template_langs

        def request_compilation(language, options)
          #todo: validate me
          requested_langs[language.downcase] = options
        end

        def register_language(language, writer_class)
          available_langs[language.downcase] = writer_class
        end

        def register_template(language, template_name, template_root)
          template_langs[language.downcase] ||= []

          find_path = File.join(File.dirname(template_root), language, template_name + '.*.erb')
          template_path = Dir[find_path].first #todo: handle cases when there is more than 1 file

          template_langs[language.downcase] << {name: template_name.downcase, find_query: find_path, path: template_path}
        end

        def find_template(language, template_name)
          templates = template_langs[language.downcase]
          return nil if templates.nil?

          templates.find do |template|
            template[:name] == template_name.downcase
          end
        end

        def load_templates
          dirname = File.dirname(__FILE__) + '/'
          Dir[dirname + '**/*.erb'].map do |template_path|
            names = template_path.sub(dirname, '').split('/')
            register_template names.first, names.last, template_path
          end
        end

        def write_all
          requested_langs.each do |language, options|
            writer = available_langs[language].new DEFAULT_OPTIONS.dup.merge(options)
            writer.write!
          end
        end

        def clear
          [@requested_langs, @available_langs, @template_langs].each(&:clear)
        end
      end
    end
  end
end
