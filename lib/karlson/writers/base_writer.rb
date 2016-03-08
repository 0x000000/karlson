module Karlson
  module Writers
    class BaseWriter
      def self.inherited(writer_class)
        lang_name, _ = Utils::File.fetch_lang_names_by(writer_class.name)
        Karlson::Writers::LangsRegistry.register_language(lang_name, writer_class)
      end

      attr_reader :options, :commands

      def initialize(options = {})
        @options = options
        @commands = []
      end

      def write!(file_structure = nil)
        raise ArgumentError, 'Please provide the `file_structure` argument' if file_structure.nil?

        file_structure.each do |dir, dir_structure|
          handle_tree dir, dir_structure
        end
      end

      private

      def handle_tree(dir, dir_structure)
        if dir_structure.is_a? Hash
          commands << [:create_dir, dir.to_s]
          commands << [:goto_dir, dir.to_s]

          dir_structure.each do |subdir, subdir_structure|
            handle_tree subdir, subdir_structure
          end

          commands << [:goto_dir, :back]
        elsif dir_structure == nil
          commands << [:create_dir, dir.to_s]
        elsif dir_structure.superclass == Karlson::Writers::BaseRender
          commands << [:create_file, dir.to_s, dir_structure]
        end
      end
    end
  end
end
