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
  let(:project) { Enginn::Project.new(client, { id: 1 }) }

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
      expect(FakesIndex.new(project).pagination[:current]).to eq(1)
    end

    it 'sets empty filters' do
      expect(FakesIndex.new(project).filters).to eq({})
    end
  end

  describe '#fetch!' do
    let(:fakes_index) { FakesIndex.new(project) }

    context 'when the request has succeeded' do
      before do
        stubs.get("#{Enginn::Client::BASE_URL}/projects/1/fakes") do |env|
          ApiStub.new(env).response
        end
      end

      it 'returns true' do
        expect(fakes_index.fetch!).to be true
      end
    end

    context 'when the request has failed' do
      before do
        stubs.get("#{Enginn::Client::BASE_URL}/projects/1/fakes") do
          [
            500,
            { 'Content-Type' => 'application/json' },
            { error: { foo: 'this is an error' } }
          ]
        end
      end

      it 'raises an error' do
        expect { fakes_index.fetch! }.to raise_error(Faraday::Error)
      end
    end
  end

  describe '#fetch' do
    let(:fakes_index) { FakesIndex.new(project) }

    context 'when the request has succeeded' do
      before do
        stubs.get("#{Enginn::Client::BASE_URL}/projects/1/fakes") do |env|
          ApiStub.new(env).response
        end
      end

      it 'returns true' do
        expect(fakes_index.fetch).to be true
      end
    end

    context 'when the request has failed' do
      before do
        stubs.get("#{Enginn::Client::BASE_URL}/projects/1/fakes") do
          [
            500,
            { 'Content-Type' => 'application/json' },
            { error: { foo: 'this is an error' } }
          ]
        end
      end

      it 'does not raise errors' do
        expect { fakes_index.fetch }.not_to raise_error
      end

      it 'returns false' do
        expect(fakes_index.fetch).to be false
      end

      it 'fills in #errors' do
        fakes_index.fetch
        expect(fakes_index.errors).not_to be_empty
      end
    end
  end

  describe '#each' do
    let(:fakes_index) { FakesIndex.new(project) }

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
    let(:fakes_index) { FakesIndex.new(project) }

    it 'returns a copy of the object' do
      expect(fakes_index.page(2)).not_to be(fakes_index)
    end

    it 'updates the current page' do
      expect(fakes_index.page(2).pagination[:current]).to eq(2)
    end
  end

  describe '#per' do
    let(:fakes_index) { FakesIndex.new(project) }

    it 'returns a copy of the object' do
      expect(fakes_index.per(10)).not_to be(fakes_index)
    end

    it 'updates the number of items per page' do
      expect(fakes_index.per(10).pagination[:per]).to eq(10)
    end
  end

  describe '#where' do
    let(:fakes_index) { FakesIndex.new(project) }

    context 'when there is no existing filters' do
      it 'sets the filters to equal the given argument' do
        expect(fakes_index.where(foo: 1).filters).to eq(foo: 1)
      end
    end

    context 'when there are filters already' do
      it 'merges existing filters and new ones' do
        index = fakes_index.where(foo: 1)
        expect(index.where(bar: 2).filters).to eq(foo: 1, bar: 2)
      end
    end

    it 'returns a copy of the object' do
      expect(fakes_index.where(bar: 2)).not_to be(fakes_index)
    end
  end

  describe '#inspect' do
    it 'returns a string' do
      expect(FakesIndex.new(project).inspect).to be_a(String)
    end
  end
end
