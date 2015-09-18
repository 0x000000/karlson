require "spec_helper"

module Karlson::Readers
  describe "Pack" do
    before { TypesRegistry.clear }

    context 'with default options' do
      before do
        enum :foo_bar do
          baz 1
        end

        pack :zoo do
          doo 1, :boolean
        end

        pack :valid do
          a1 1, :string
          a2 2, :number
          a3 3, :boolean
          a4 4, :foo_bar
          a5 5, :zoo
          a6 6, [:foo_bar]
          a7 7, {:string => :zoo}
        end

        TypesRegistry.compute_all
      end

      let(:info) { TypesRegistry.pack(:valid).type_info }

      it 'should detect internal_type and types' do
        expect(info[:fields][1][:internal_type]).to eq :string
        expect(info[:fields][1][:type]).to eq :string

        expect(info[:fields][2][:internal_type]).to eq :number
        expect(info[:fields][2][:type]).to eq :number

        expect(info[:fields][3][:internal_type]).to eq :boolean
        expect(info[:fields][3][:type]).to eq :boolean

        expect(info[:fields][4][:internal_type]).to eq :enum
        expect(info[:fields][4][:type]).to eq :foo_bar

        expect(info[:fields][5][:internal_type]).to eq :pack
        expect(info[:fields][5][:type]).to eq :zoo

        expect(info[:fields][6][:internal_type]).to eq :list
        expect(info[:fields][6][:type]).to eq [:foo_bar]

        expect(info[:fields][7][:internal_type]).to eq :map
        expect(info[:fields][7][:type]).to eq({:string => :zoo})
      end

      it 'should create default values options' do
        expect(info[:fields][1][:default]).to be_nil
        expect(info[:fields][1][:required]).to be false

        expect(info[:fields][2][:default]).to be_nil
        expect(info[:fields][2][:required]).to be false

        expect(info[:fields][3][:default]).to be_nil
        expect(info[:fields][3][:required]).to be false

        expect(info[:fields][4][:default]).to be_nil
        expect(info[:fields][4][:required]).to be false

        expect(info[:fields][5][:default]).to be_nil
        expect(info[:fields][5][:required]).to be false

        expect(info[:fields][6][:default]).to be_nil
        expect(info[:fields][6][:required]).to be false

        expect(info[:fields][7][:default]).to be_nil
        expect(info[:fields][7][:required]).to be false
      end
    end

    context 'with user-defined options' do
      it 'should create default values options' do
        pack :valid do
          a1 1, :string, :default => '[]'
          a2 2, :number, :required => true
        end

        TypesRegistry.compute_all

        info = TypesRegistry.pack(:valid).type_info

        expect(info[:fields][1][:default]).to eq '[]'
        expect(info[:fields][1][:required]).to be false

        expect(info[:fields][2][:default]).to be_nil
        expect(info[:fields][2][:required]).to be true
      end

      context 'validations for' do
        describe ':required option' do
          it 'should accetpt only boolean values' do
            expect {
              pack :invalid do
                a1 1, :string, :required => ''
              end

              TypesRegistry.compute_all
            }.to raise_error(Exception, /Field options :required should be a boolean value/)
          end
        end

        describe ':default option' do

          context 'for simple types' do
            it 'should accept proper values for types' do
              expect {
                pack :valid do
                  a1 1, :number, :default => 1
                  a2 2, :string, :default => ''
                  a3 3, :boolean, :default => false
                end

                TypesRegistry.compute_all
              }.to_not raise_error
            end

            it 'should allow only strings for :string type' do
              expect {
                pack :invalid_str do
                  a1 1, :string, :default => 1
                end

                TypesRegistry.compute_all
              }.to raise_error(Exception, /Field options default: for :string type should be a string or nil/)
            end

            it 'should allow only numbers for :number type' do
              expect {
                pack :invalid_num do
                  a1 1, :number, :default => ''
                end

                TypesRegistry.compute_all
              }.to raise_error(Exception, /Field options default: for :number type should be a number or nil/)
            end

            it 'should allow only boolean values for :boolean type' do
              expect {
                pack :invalid_bool do
                  a1 1, :boolean, :default => ''
                end

                TypesRegistry.compute_all
              }.to raise_error(Exception, /Field options default: for :boolean type should be a boolean or nil/)
            end
          end

          context 'for enums' do
            it 'should do nothing with valid defauls' do
              expect {
                enum :super_enum do
                  super_man 0
                  spider_man 100
                end

                pack :valid_pack do
                  hero 1, :super_enum, :default => 0
                end

                pack :another_valid_pack do
                  hero 1, :super_enum, :default => 100
                end

                TypesRegistry.compute_all
              }.to_not raise_error
            end

            it 'should allow only numbers as default value' do
              expect {
                enum :super_enum do
                  super_man 0
                end

                pack :invalid_pack do
                  hero 1, :super_enum, :default => ''
                end

                TypesRegistry.compute_all
              }.to raise_error(Exception, /Field options default: for :enum type should be a number or nil/)
            end
          end

          context 'for packs' do
            it 'raises not implemented' do
              expect {
                pack :valid_pack do
                  test 1, :string
                end

                pack :another_valid_pack do
                  some_pack 1, :valid_pack, :default => ''
                end

                TypesRegistry.compute_all
              }.to raise_error(Exception, /Field options default: for :pack type is not implemented yet/)
            end
          end

          context 'for lists' do
            it 'raises not implemented' do
              expect {
                pack :some_list do
                  foo 1, [:string], :default => ''
                end

                TypesRegistry.compute_all
              }.to raise_error(Exception, /Field options default: for :list type is not implemented yet/)
            end
          end

          context 'for maps' do
            it 'raises not implemented' do
              expect {
                pack :some_map do
                  bar 1, {:string => :string}, :default => ''
                end

                TypesRegistry.compute_all
              }.to raise_error(Exception, /Field options default: for :map type is not implemented yet/)
            end
          end
        end
      end
    end
  end
end
