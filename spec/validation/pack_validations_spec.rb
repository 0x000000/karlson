require 'spec_helper'

module Karlson::Readers
  describe 'Pack validations' do

    before { TypesRegistry.clear }

    describe 'packs name' do
      it 'should be' do
        expect {
          pack do
            one 1, :string
          end
        }.to raise_error(Exception, /Pack name should be presented/)
      end

      it 'should be a symbol' do
        expect {
          pack 'foo' do
            string 1
          end
        }.to raise_error(Exception, /Pack name should be a symbol/)
      end

      it 'should contain only safe symbols' do
        expect {
          pack :'xxx@foo' do
            one 1, :string
          end
        }.to raise_error(Exception, /Pack name should contain only \[a\-z\], \[0\-9\] and _ chars/)
      end

      it 'should not start with numbers' do
        expect {
          pack :'4ssss' do
            one 1, :string
          end
        }.to raise_error(Exception, /Pack name should not start with numbers/)
      end

      it 'should be uniq' do
        expect {
          pack :'one' do
            one 1, :string
          end

          pack :one do
            one 1, :string
          end
        }.to raise_error(Exception, /Pack name should be uniq/)
      end

      it 'should not be system type' do
        expect {
          pack :string do
            one 1, :string
          end
        }.to raise_error(Exception, /Pack name should not be one of reserved words/)
      end
    end

    describe 'field position' do
      it 'should accept only numbers as position values' do
        expect {
          pack :test do
            one 'test'
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position should be an integer number/)
      end

      it 'should accept hexdecimal numbers as position values' do
        expect {
          pack :test do
            foo 0x1, :string
          end

          TypesRegistry.compute_all
        }.to_not raise_error
      end

      it 'should not accept negative numbers as position values' do
        expect {
          pack :test do
            foo -1, :string
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position should be a positive number or 0/)
      end

      it 'should not accept negative numbers as position values' do
        expect {
          pack :test do
            foo 100.5, :string
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position should be an integer number/)
      end

      it 'should not accept negative numbers as position values' do
        expect {
          pack :test do
            foo 100_000, :string
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position should be lesser than 32767/)
      end

      it 'should be uniq' do
        expect {
          pack :test do
            foo 1, :string
            foo2 1, :string
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position with number 1 already defined here/)
      end
    end

    describe 'field type' do
      it 'should be' do
        expect {
          pack :test do
            one 1
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field type should be presented/)
      end

      it 'should be a proper type' do
        expect {
          pack :test do
            one 1, 'one'
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field type should be a symbol, list or map/)
      end

      describe 'when type is symbol' do
        it 'should be defined or system type' do
          expect {
            pack :test do
              one 1, :unknown_type
            end

            TypesRegistry.compute_all
          }.to raise_error(Exception, /unknown_type type not defined/)
        end
      end

      describe 'when type is list' do
        it 'should be a proper type' do
          expect {
            pack :test do
              one 1, [:unknown_type]
            end

            TypesRegistry.compute_all
          }.to raise_error(Exception, /unknown_type type not defined/)
        end

        it 'should understand system types' do
          expect {
            pack :test do
              one 1, [:string]
              two 2, [:boolean]
              three 3, [:number]
            end

            TypesRegistry.compute_all
          }.to_not raise_error
        end

        it 'should understand enum and pack types' do
          expect {

            enum :foo do
              bar 1
            end

            pack :baz do
              xxx 1, :string
            end

            pack :test do
              one 1, [:foo]
              two 2, [:baz]
            end

            TypesRegistry.compute_all
          }.to_not raise_error
        end
      end

      describe 'when type is map' do
        it 'should be a proper type' do
          expect {
            pack :test do
              one 1, {:unknown_type => :string}
            end

            TypesRegistry.compute_all
          }.to raise_error(Exception, /unknown_type type not defined/)

          expect {
            pack :test2 do
              one 1, {:string => :unknown_type}
            end

            TypesRegistry.compute_all
          }.to raise_error(Exception, /unknown_type type not defined/)

        end

        it 'should understand system types' do
          expect {
            pack :test do
              one 1, {:string => :string}
              two 2, {:boolean => :boolean}
              three 3, {:number => :number}
            end

            TypesRegistry.compute_all
          }.to_not raise_error
        end

        it 'should understand enum and pack types' do
          expect {

            enum :foo do
              bar 1
            end

            pack :baz do
              xxx 1, :string
            end

            pack :test do
              one 1, {:string => :foo}
              two 2, {:string => :baz}
            end

            TypesRegistry.compute_all
          }.to_not raise_error
        end

        it 'should not allow user types as map key type' do
          expect {

            enum :foo do
              bar 1
            end

            pack :test do
              one 1, {:foo => :string}
            end

            TypesRegistry.compute_all
          }.to raise_error(Exception, /only system types allowed as map keys/)
        end
      end

    end

    describe 'field name' do
      it 'should be uniq' do
        expect {
          pack :test do
            one 1, :string
            one 2, :string
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field name with name :one already defined here/)
      end
    end

  end
end