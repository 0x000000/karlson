require 'spec_helper'

module Karlson::Readers
  describe EmptyObject do
    let(:object) { EmptyObject.new }

    context 'when created' do
      it 'should initialize @fields list' do
        expect(object.instance_eval { @fields }).to eq []
      end
    end

    describe 'random method call' do
      it 'should transform method call to field list' do
        object.foo 12, :xx, aa: 1
        expect(object.instance_eval { @fields }).to eq [[:foo, [12, :xx, {aa: 1}]]]
      end

      context 'without params' do
        it 'should transform method call to field list' do
          object.foo
          expect(object.instance_eval { @fields }).to eq [[:foo, []]]
        end
      end
    end

    describe '#method_missing' do
      it 'should transform method call to field list' do
        object.method_missing 12, :xx, aa: 1
        expect(object.instance_eval { @fields }).to eq [[:method_missing, [12, :xx, {aa: 1}]]]
      end
    end

    describe '#initialize' do
      it 'should transform method call to field list' do
        object.instance_eval do
          initialize 12
        end

        expect(object.instance_eval { @fields }).to eq [[:initialize, [12]]]
      end
    end

    describe '#__id__' do
      it 'should transform method call to field list' do
        object.__id__ 12, :xx, aa: 1
        expect(object.instance_eval { @fields }).to eq [[:__id__, [12, :xx, {aa: 1}]]]
      end
    end

    describe '#__send__' do
      context 'called with Integer as a first arg' do
        it 'should transform method call to field list' do
          object.__send__ 12, :xx, aa: 1
          expect(object.instance_eval { @fields }).to eq [[:__send__, [12, :xx, {aa: 1}]]]
        end
      end

      context 'called with Symbol as a first arg' do
        it 'should call method' do
          object.__send__ :foo, 12, :xx, aa: 1
          expect(object.instance_eval { @fields }).to eq [[:foo, [12, :xx, {aa: 1}]]]
        end
      end
    end

    describe '#instance_eval' do
      it 'should transform method call to field list' do
        object.instance_eval 12, :xx, aa: 1
        expect(object.instance_eval { @fields }).to eq [[:instance_eval, [12, :xx, {aa: 1}]]]
      end
    end

    describe '#instance_exec' do
      it 'should transform method call to field list' do
        object.instance_exec 12, :xx, aa: 1
        expect(object.instance_eval { @fields }).to eq [[:instance_exec, [12, :xx, {aa: 1}]]]
      end
    end

    describe '#singleton_method_added' do
      it 'should transform method call to field list' do
        object.singleton_method_added 12, :xx, aa: 1
        expect(object.instance_eval { @fields }).to eq [[:singleton_method_added, [12, :xx, {aa: 1}]]]
      end
    end

    describe '#singleton_method_removed' do
      it 'should transform method call to field list' do
        object.singleton_method_removed 12, :xx, aa: 1
        expect(object.instance_eval { @fields }).to eq [[:singleton_method_removed, [12, :xx, {aa: 1}]]]
      end
    end

    describe '#singleton_method_undefined' do
      it 'should transform method call to field list' do
        object.singleton_method_undefined 12, :xx, aa: 1
        expect(object.instance_eval { @fields }).to eq [[:singleton_method_undefined, [12, :xx, {aa: 1}]]]
      end
    end
  end
end
