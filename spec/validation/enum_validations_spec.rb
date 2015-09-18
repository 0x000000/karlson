require 'spec_helper'

module Karlson::Readers
  describe 'Enum validations' do

    before { TypesRegistry.clear }

    describe 'name' do
      it 'should be' do
        expect {
          enum do
            one 1
          end

        }.to raise_error(Exception, /Enum name should be presented/)
      end

      it 'should be a symbol' do
        expect {
          enum 'foo' do
            one 1
          end

        }.to raise_error(Exception, /Enum name should be a symbol/)
      end

      it 'should contain only safe symbols' do
        expect {
          enum :'xxx@foo' do
            one 1
          end

        }.to raise_error(Exception, /Enum name should contain only \[a\-z\], \[0\-9\] and _ chars/)
      end

      it 'should not start with numbers' do
        expect {
          enum :'4ssss' do
            one 1
          end

        }.to raise_error(Exception, /Enum name should not start with numbers/)
      end

      it 'should be uniq' do
        expect {
          enum :'one' do
            one 1
          end

          enum :one do
            one 1
          end
        }.to raise_error(Exception, /Enum name should be uniq/)
      end

      it 'should not be system type' do
        expect {
          enum :string do
            one 1
          end

        }.to raise_error(Exception, /Enum name should not be one of reserved words/)
      end
    end

    describe 'field position' do
      it 'should be' do
        expect {
          enum :test do
            one
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position should be presented/)
      end

      it 'should accept only numbers as position values' do
        expect {
          enum :test do
            one :one
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position should be an integer number/)
      end

      it 'should accept hexdecimal numbers as position values' do
        expect {
          enum :test do
            one 0x1
          end

          TypesRegistry.compute_all
        }.to_not raise_error
      end

      it 'should not accept negative numbers as position values' do
        expect {
          enum :test do
            one -1
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position should be a positive number or 0/)
      end

      it 'should not accept negative numbers as position values' do
        expect {
          enum :test do
            one 100.5
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position should be an integer number/)
      end

      it 'should not accept negative numbers as position values' do
        expect {
          enum :test do
            one 100_000
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position should be lesser than 32767/)
      end

      it 'should be uniq' do
        expect {
          enum :test do
            one 1
            two 1
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position with number 1 already defined here/)
      end

      it 'should be uniq' do
        expect {
          enum :test2 do
            one 16
            two 0x10
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field position with number 16 already defined here/)
      end
    end

    describe 'field name' do
      it 'should be uniq' do
        expect {
          enum :test do
            one 1
            one 2
          end

          TypesRegistry.compute_all
        }.to raise_error(Exception, /Field name with name :one already defined here/)
      end
    end
  end
end
