# frozen_string_literal: true

class ApiStub
  def initialize(env)
    @env = env
    @collection = [
      { id: 1, name: 'Indiana', size: 'smol' },
      { id: 2, name: 'Jones', size: 'big' }
    ]
  end

  def response
    [
      200,
      { 'Content-Type' => 'application/json' },
      body
    ]
  end

  private

  def body
    page = @env.params['page']&.to_i || 1
    per = @env.params['per']&.to_i || 25
    items = @collection.each_slice(per).to_a
    {
      result: items[page - 1],
      pagination: { current: page, per: per, last: items.size, count: @collection.size }
    }
  end
end

class Fake < Enginn::Resource
  def self.path
    'fakes'
  end
end

class FakesIndex < Enginn::ResourceIndex
  def self.resource
    Fake
  end
end

RSpec.describe Enginn::ResourceIndex do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) { Enginn::Client.new(api_token: '12345') }
  let(:project) { Enginn::Project.new(client, { uid: 1 }) }

  before do
    client.connection do |conn|
      conn.adapter :test, stubs
      # Uncomment to help debugging stubs
      # conn.response :logger
    end
  end

  after do
    Faraday.default_connection = nil
  end

  describe '#initialize' do
    it 'sets the current page to 1' do
      expect(FakesIndex.new(client, project).pagination[:current]).to eq(1)
    end

    it 'sets empty filters' do
      expect(FakesIndex.new(client, project).filters).to eq({})
    end
  end

  describe '#each' do
    let(:fakes_index) { FakesIndex.new(client, project) }

    before do
      stubs.get("#{Enginn::Client::BASE_URL}/projects/1/fakes") do |env|
        ApiStub.new(env).response
      end
    end

    context 'when there is only one page' do
      it 'yields all the items in the collection' do
        expect(fakes_index.per(2).page(1).map(&:name)).to eq(%w[Indiana Jones])
      end
    end

    context 'when there is multiple pages' do
      it 'yields all the items in the collection' do
        expect(fakes_index.per(1).map(&:name)).to eq(%w[Indiana Jones])
      end
    end
  end

  describe '#page' do
    let(:fakes_index) { FakesIndex.new(client, project) }

    it 'updates the current page' do
      fakes_index.page(2)
      expect(fakes_index.pagination[:current]).to eq(2)
    end

    it 'returns self' do
      expect(fakes_index.page(2)).to be(fakes_index)
    end
  end

  describe '#per' do
    let(:fakes_index) { FakesIndex.new(client, project) }

    it 'updates the number of items per page' do
      fakes_index.per(10)
      expect(fakes_index.pagination[:per]).to eq(10)
    end

    it 'returns self' do
      expect(fakes_index.per(10)).to be(fakes_index)
    end
  end

  describe '#where' do
    let(:fakes_index) { FakesIndex.new(client, project) }

    context 'when there is no existing filters' do
      it 'sets the filters to equal the given argument' do
        fakes_index.where(foo: 1)
        expect(fakes_index.filters).to eq(foo: 1)
      end
    end

    context 'when there are filters already' do
      before { fakes_index.where(foo: 1) }

      it 'merges existing filters and new ones' do
        fakes_index.where(bar: 2)
        expect(fakes_index.filters).to eq(foo: 1, bar: 2)
      end
    end

    it 'returns self' do
      expect(fakes_index.where({})).to be(fakes_index)
    end
  end

  describe '#inspect' do
    it 'returns a string' do
      expect(FakesIndex.new(client, project).inspect).to be_a(String)
    end
  end
end
