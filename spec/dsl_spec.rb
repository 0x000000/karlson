require 'spec_helper'

describe Karlson::DSL do
  let(:test_dsl) do
    Class.new do
      include Karlson::DSL
    end
  end

  let(:instance_with_dsl_included) { test_dsl.new }

  it 'declares enum, pack and compile_to methods' do
    expect(instance_with_dsl_included.respond_to?(:pack)).to be true
    expect(instance_with_dsl_included.respond_to?(:enum)).to be true
    expect(instance_with_dsl_included.respond_to?(:compile_to)).to be true
  end
end
