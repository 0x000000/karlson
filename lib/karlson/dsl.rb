module Karlson
  module DSL
    def enum(name = nil, &block)
      Karlson::Readers::TypesRegistry.register Karlson::Readers::EnumReader.new(name, &block)
    end

    def pack(name = nil, &block)
      Karlson::Readers::TypesRegistry.register Karlson::Readers::PackReader.new(name, &block)
    end

    def compile_to(language = nil, options = {})
      Karlson::Writers::LangsRegistry.request_compilation(language, options)
    end
  end
end
