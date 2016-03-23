require 'spec_helper'

describe Utils::File do
  describe '.fetch_lang_names_by' do
    context 'with simple class name' do
      let(:name) { Utils::File.name }
      it { expect(Utils::File.fetch_lang_names_by(name)).to eq ['utils', 'file'] }
    end

    context 'with complex class name' do
      let(:name) { Karlson::Writers::BaseWriter.name }

      it { expect(Utils::File.fetch_lang_names_by(name)).to eq ['writers', 'base_writer'] }
    end
  end
end
