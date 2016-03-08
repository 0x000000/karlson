module Karlson
  module Writers
    class BaseRender
      attr_reader :options, :template_path

      def self.inherited(render_class)
        lang_name, template_name = Utils::File.fetch_lang_names_by(render_class.name)
        LangsRegistry.register_template(lang_name, template_name, File.expand_path(__FILE__))
      end

      def initialize(options = {})
        @options       = {erb: '%<>-'}.merge(options)
        @template_path = restore_template_path
      end

      def render
        template = File.open(template_path) { |f| f.read }
        ERB.new(template, nil, @options[:erb]).result(binding)
      end

      private

      def restore_template_path
        lang_name, template_name = Utils::File.fetch_lang_names_by(self.class.name)
        LangsRegistry.find_template(lang_name, template_name)[:path] #todo: handle situation when there is no template or path
      end
    end
  end
end
