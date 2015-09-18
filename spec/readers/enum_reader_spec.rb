require 'spec_helper'

module Karlson::Readers
  describe 'TypesRegistry for enums' do
    before :all do
      TypesRegistry.clear

      enum :robots do
        bender     0
        terminator 10
        robocop    20
      end

      TypesRegistry.compute_all
    end

    it 'should register enum as user type' do
      expect(TypesRegistry.enums.size).to eq 1
    end

    context 'and enum_type_information' do
      let(:enum_type_information) { TypesRegistry.enum(:robots).type_info }

      it { expect(enum_type_information).to be }

      describe 'property :type' do
        it { expect(enum_type_information[:type]).to eq :enum }
      end

      describe 'property :name' do
        it { expect(enum_type_information[:name]).to eq :robots }
      end

      describe 'property :fields_names' do
        it 'should include all fields names' do
          expect(enum_type_information[:fields_names]).to eq [:bender, :terminator, :robocop]
        end
      end

      describe 'property :fields_positions' do
        it 'should include all fields positions' do
          expect(enum_type_information[:fields_positions]).to eq [0, 10, 20]
        end
      end

      describe 'property :fields' do
        subject { enum_type_information[:fields] }

        context 'as hash' do
          it 'should contain fields positions as keys' do
            expect(subject.keys).to eq [0, 10, 20]
          end

          it 'should contain information about field names and options as values' do
            expect(subject.values).to eq [
              {name: :bender},
              {name: :terminator},
              {name: :robocop}
            ]
          end
        end
      end
    end

  end
end
