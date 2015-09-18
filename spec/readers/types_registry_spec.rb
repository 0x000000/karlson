require 'spec_helper'

module Karlson::Readers
  describe TypesRegistry do
    before { TypesRegistry.clear }

    context 'when TypesRegistry does not contain any builders' do
      it { expect(TypesRegistry.enums).to eq [] }
      it { expect(TypesRegistry.packs).to eq [] }
      it { expect(TypesRegistry.user_types).to eq [] }
      it { expect(TypesRegistry.internal_types_mapping).to eq({string: :string, boolean: :boolean, number: :number}) }
    end

    context 'for enum' do
      before do
        enum :aloha do
          one 1
        end
      end

      context 'before computed' do
        it { expect(TypesRegistry.enums.size).to eq 1 }
        it { expect(TypesRegistry.packs).to eq [] }
        it { expect(TypesRegistry.user_types).to eq [:aloha] }
        it { expect(TypesRegistry.internal_types_mapping).to eq({string: :string, boolean: :boolean, number: :number, aloha: :enum}) }
        it { expect(TypesRegistry.enum(:aloha).type_info).to eq({type: :enum, name: :aloha, fields_names: [], fields_positions: [], fields: {}}) }
      end

      context 'after computed' do
        before { TypesRegistry.compute_all }

        it { expect(TypesRegistry.enums.size).to eq 1 }
        it { expect(TypesRegistry.packs).to eq [] }
        it { expect(TypesRegistry.user_types).to eq [:aloha] }
        it { expect(TypesRegistry.internal_types_mapping).to eq({string: :string, boolean: :boolean, number: :number, aloha: :enum}) }
        it { expect(TypesRegistry.enum(:aloha).type_info).to eq({type: :enum, name: :aloha, fields_names: [:one], fields_positions: [1], fields: {1 => {:name => :one}}}) }
      end
    end

    context 'when pack created' do
      before do
        pack :little_green_man do
          one 1, :string
        end
      end

      it { expect(TypesRegistry.packs.size).to eq 1 }
      it { expect(TypesRegistry.enums).to eq [] }
      it { expect(TypesRegistry.user_types).to eq [:little_green_man] }
      it { expect(TypesRegistry.internal_types_mapping).to eq({string: :string, boolean: :boolean, number: :number, little_green_man: :pack}) }
      it { expect(TypesRegistry.pack(:little_green_man).type_info).to eq({type: :pack, name: :little_green_man, fields_types: [], fields_names: [], fields_positions: [], fields_options: [], fields: {}}) }
    end

    describe '::compute_all' do
      context 'when TypesRegistry does not contain any builders' do
        it { expect { TypesRegistry.compute_all }.to_not raise_error }
      end

      context 'with enums and packs' do
        before do
          enum :commands do
            initialize 1
            destroy 2
          end

          pack :order do
            command 1, [:commands]
          end
        end

        it { expect { TypesRegistry.compute_all }.to_not raise_error }
      end
    end
  end
end
