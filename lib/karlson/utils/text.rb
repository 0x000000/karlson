module Utils
  module Text
    class << self
      def upper_camel_case(text)
        text.downcase.split('_').map(&:capitalize).join
      end

      def lower_camel_case(text)
        text.downcase.split('_').map.with_index { |word, i| i == 0 ? word : word.capitalize }.join
      end

      def underscore_case(text)
        text.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
          gsub(/([a-z\d])([A-Z])/, '\1_\2').
          tr('-', '_').downcase
      end
    end
  end
end
