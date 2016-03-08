require 'spec_helper'

describe Utils::Text do
  describe '.upper_camel_case' do
    it { expect(Utils::Text.upper_camel_case('foo_bar')).to eq 'FooBar' }
    it { expect(Utils::Text.upper_camel_case('foo_barBaz')).to eq 'FooBarbaz' }
  end

  describe '.lower_camel_case' do
    it { expect(Utils::Text.lower_camel_case('foo_bar')).to eq 'fooBar' }
    it { expect(Utils::Text.lower_camel_case('Foofoo_bar')).to eq 'foofooBar' }
  end

  describe '.underscore_case' do
    it { expect(Utils::Text.underscore_case('fooBar')).to eq 'foo_bar' }
    it { expect(Utils::Text.underscore_case('fooBar::Foo')).to eq 'foo_bar/foo' }
  end
end
