require 'spec_helper'

module Karlson::Readers
  describe "TypesRegistry for packs" do
    before :all do
      TypesRegistry.clear

      enum :robots do
        bender     0
        terminator 10
        robocop    20
      end

      pack :date do
        day    1, :number
        mounth 2, :number
        year   3, :number
      end

      pack :famous_robots do
        label        0, :string
        age          1, :number,  default: 0, required: true
        smoker       2, :boolean, default: nil, required: true
        movies       3, [:string]
        birthday     5, :date
        movies_dates 10, {:string => :date}
      end

      TypesRegistry.compute_all
    end

    it 'should register packs as user types' do
      expect(TypesRegistry.packs.size).to eq 2
    end

    context 'and type_info' do
      let(:type_info) { TypesRegistry.pack(:famous_robots).type_info }

      it { expect(type_info).to be }

      describe 'property :type' do
        it { expect(type_info[:type]).to eq :pack }
      end

      describe 'property :name' do
        it { expect(type_info[:name]).to eq :famous_robots }
      end

      describe 'property :fields_names' do
        it 'should include all fields names' do
          expect(type_info[:fields_names]).to eq [:label, :age, :smoker, :movies, :birthday, :movies_dates]
        end
      end

      describe 'property :fields_positions' do
        it 'should include all fields positions' do
          expect(type_info[:fields_positions]).to eq [0, 1, 2, 3, 5, 10]
        end
      end

      describe 'property :fields_types' do
        it 'should include all fileds types' do
          expect(type_info[:fields_types]).to eq [:string, :number, :boolean, [:string], :date, {:string=>:date}]
        end
      end

      describe 'property :fields' do
        subject { type_info[:fields] }

        context 'as hash' do
          it 'should contain fields positions as keys' do
            expect(subject.keys).to eq [0, 1, 2, 3, 5, 10]
          end

          it 'should contain information about field names and options as values' do
            expect(subject.values).to eq [
                {:default => nil, :required => false, :name => :label,        :type => :string,             :internal_type => :string},
                {:default => 0,   :required => true,  :name => :age,          :type => :number,             :internal_type => :number},
                {:default => nil, :required => true,  :name => :smoker,       :type => :boolean,            :internal_type => :boolean},
                {:default => nil, :required => false, :name => :movies,       :type => [:string],           :internal_type => :list},
                {:default => nil, :required => false, :name => :birthday,     :type => :date,               :internal_type => :pack},
                {:default => nil, :required => false, :name => :movies_dates, :type => {:string => :date},  :internal_type => :map}
            ]
          end
        end
      end
    end

  end
end
