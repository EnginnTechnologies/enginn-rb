RSpec.describe Enginn::StringUtils do
  describe '.underscore' do
    it { expect(described_class.underscore('Foo')).to eq ('foo') }
    it { expect(described_class.underscore('FooBar')).to eq ('foo_bar') }
    it { expect(described_class.underscore('foo')).to eq ('foo') }
    it { expect(described_class.underscore('foobar')).to eq ('foobar') }
    it { expect(described_class.underscore('FOOBAR')).to eq ('foobar') }
    it { expect(described_class.underscore('Foo-bar_Baz')).to eq ('foo_bar_baz') }
  end
end
