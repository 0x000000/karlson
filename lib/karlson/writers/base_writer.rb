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

        prepare_commands! file_structure
        execute_commands!
      end

      private

      def prepare_commands!(file_structure)
        working_dir = if options[:working_dir].nil?
                        Dir.pwd
                      else
                        File.expand_path @options[:working_dir]
                      end

        @commands = [[:goto_dir, working_dir]]

        file_structure.each do |dir, dir_structure|
          parse_tree dir, dir_structure
        end
      end

      def parse_tree(dir, dir_structure)
        if dir_structure.is_a? Hash                                       # create subdir and operate inside it
          @commands << [:create_dir, dir.to_s]
          @commands << [:goto_dir, dir.to_s]

          dir_structure.each do |subdir, subdir_structure|
            parse_tree subdir, subdir_structure
          end

          @commands << [:goto_dir, '..']
        elsif dir_structure == nil                                        # create empty dir
          @commands << [:create_dir, dir.to_s]
        elsif dir_structure.superclass == Karlson::Writers::BaseRender    # render writer content to the file
          @commands << [:create_file, dir.to_s, dir_structure]
        end
      end

      def execute_commands!
        commands.each do |command|
          case command[0]
          when :create_dir
            FileUtils.mkdir_p command[1]

          when :goto_dir
            FileUtils.cd command[1]

          when :create_file
            file_name = File.join(Dir.pwd, command[1])
            File.open(file_name, 'w+') do |f|
              f.write command[2].new.render
            end

          else
            raise ArgumentError, "Unknown command: #{command}"
          end
        end
      end
    end
  end
end
