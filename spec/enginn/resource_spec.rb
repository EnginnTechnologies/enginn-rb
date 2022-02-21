# frozen_string_literal: true

class FakeResource < Enginn::Resource
  def self.path
    'fakes'
  end
end

RSpec.describe Enginn::Resource do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) { Enginn::Client.new(api_token: '12345') }
  let(:project) { Enginn::Project.new(client, id: 1) }

  before do
    client.connection do |conn|
      conn.adapter :test, stubs
    end

    stubs.get("#{Enginn::Client::BASE_URL}/projects/1") do |_|
      [
        200,
        { 'Content-Type': 'application/json' },
        { result: { id: 1, name: 'Fake Project' } }
      ]
    end
  end

  after do
    Faraday.default_connection = nil
  end

  describe '#fetch!' do
    before do
      stubs.get("#{Enginn::Client::BASE_URL}/projects/1/fakes/0") do |_|
        [
          404,
          { 'Content-Type': 'application/json' },
          { errors: { id: 'does not exist' } }
        ]
      end
      stubs.get("#{Enginn::Client::BASE_URL}/projects/1/fakes/42") do |_|
        [
          200,
          { 'Content-Type': 'application/json' },
          { result: { id: 42, name: 'Fake' } }
        ]
      end
    end

    let(:resource) { FakeResource.new(project, { id: 42 }) }

    context 'when the request has succeeded' do
      it 'returns true' do
        expect(resource.fetch!).to be true
      end

      it 'synchronizes attributes' do
        resource.fetch!
        expect(resource.attributes).to include({ id: 42, name: 'Fake' })
      end

      it 'exposes attributes as instance methods' do
        resource.fetch!
        resource.attributes.each_key do |attr|
          expect { resource.send(attr) }.not_to raise_error
        end
      end
    end

    context 'when the request has failed' do
      it 'raises an error' do
        resource.id = 0
        expect { resource.fetch! }.to raise_error(Enginn::HTTPError)
      end
    end
  end

  describe '#fetch' do
    before do
      stubs.get("#{Enginn::Client::BASE_URL}/projects/1/fakes/0") do |_|
        [
          404,
          { 'Content-Type': 'application/json' },
          { errors: { id: 'does not exist' } }
        ]
      end
      stubs.get("#{Enginn::Client::BASE_URL}/projects/1/fakes/42") do |_|
        [
          200,
          { 'Content-Type': 'application/json' },
          { result: { id: 42, name: 'Fake' } }
        ]
      end
    end

    let(:resource) { FakeResource.new(project, { id: 42 }) }

    context 'when the request has succeeded' do
      it 'returns true' do
        expect(resource.fetch).to be true
      end

      it 'synchronizes attributes' do
        resource.fetch
        expect(resource.attributes).to include({ id: 42, name: 'Fake' })
      end

      it 'exposes attributes as instance methods' do
        resource.fetch
        resource.attributes.each_key do |attr|
          expect { resource.send(attr) }.not_to raise_error
        end
      end
    end

    context 'when the request has failed' do
      before { resource.id = 0 }

      it 'does not raise errors' do
        expect { resource.fetch }.not_to raise_error
      end

      it 'returns false' do
        expect(resource.fetch).to be false
      end

      it 'fill in #errors' do
        resource.fetch
        expect(resource.errors).not_to be_empty
      end
    end
  end

  describe '#save!' do
    before do
      stubs.post("#{Enginn::Client::BASE_URL}/projects/1/fakes/") do |env|
        [
          201,
          { 'Content-Type': 'application/json' },
          { result: JSON.parse(env.body).merge(id: 42) }
        ]
      end
      stubs.patch("#{Enginn::Client::BASE_URL}/projects/1/fakes/42") do |env|
        [
          200,
          { 'Content-Type': 'application/json' },
          { result: JSON.parse(env.body).merge(id: 42) }
        ]
      end
      stubs.patch("#{Enginn::Client::BASE_URL}/projects/1/fakes/0") do |_|
        [
          422,
          { 'Content-Type': 'application/json' },
          { errors: { id: 'does not exist' } }
        ]
      end
    end

    context 'when the resource has no ID' do
      let(:resource) { FakeResource.new(project, { name: 'Fake' }) }

      it 'creates a new resource' do
        resource.save!
        expect(resource.id).to eq(42)
      end
    end

    context 'when the resource has an ID' do
      let(:resource) { FakeResource.new(project, { id: 42, name: 'Fake' }) }

      it 'updates the resource' do
        resource.name = 'New Name'
        resource.save!
        expect(resource.name).to eq('New Name')
      end
    end

    context 'when the request has succeeded' do
      let(:resource) { FakeResource.new(project, { name: 'Fake' }) }

      it 'returns true' do
        expect(resource.save!).to be true
      end
    end

    context 'when the request has failed' do
      let(:resource) { FakeResource.new(project, { id: 0 }) }

      it 'raises an error' do
        expect { resource.save! }.to raise_error(Enginn::HTTPError)
      end
    end
  end

  describe '#save' do
    before do
      stubs.post("#{Enginn::Client::BASE_URL}/projects/1/fakes/") do |env|
        [
          201,
          { 'Content-Type': 'application/json' },
          { result: JSON.parse(env.body).merge(id: 42) }
        ]
      end
      stubs.patch("#{Enginn::Client::BASE_URL}/projects/1/fakes/42") do |env|
        [
          200,
          { 'Content-Type': 'application/json' },
          { result: JSON.parse(env.body).merge(id: 42) }
        ]
      end
      stubs.patch("#{Enginn::Client::BASE_URL}/projects/1/fakes/0") do |_|
        [
          422,
          { 'Content-Type': 'application/json' },
          { errors: { id: 'does not exist' } }
        ]
      end
    end

    context 'when the resource has no ID' do
      let(:resource) { FakeResource.new(project, { name: 'Fake' }) }

      it 'creates a new resource' do
        resource.save
        expect(resource.id).to eq(42)
      end
    end

    context 'when the resource has an ID' do
      let(:resource) { FakeResource.new(project, { id: 42, name: 'Fake' }) }

      it 'updates the resource' do
        resource.name = 'New Name'
        resource.save
        expect(resource.name).to eq('New Name')
      end
    end

    context 'when the request has succeeded' do
      let(:resource) { FakeResource.new(project, { name: 'Fake' }) }

      it 'returns true' do
        expect(resource.save).to be true
      end
    end

    context 'when the request has failed' do
      let(:resource) { FakeResource.new(project, { id: 0 }) }

      it 'does not raise errors' do
        expect { resource.save }.not_to raise_error
      end

      it 'returns false' do
        expect(resource.save).to be false
      end

      it 'fill in #errors' do
        resource.save
        expect(resource.errors).not_to be_empty
      end
    end
  end

  describe '#destroy!' do
    before do
      stubs.delete("#{Enginn::Client::BASE_URL}/projects/1/fakes/42") do |_|
        [
          200,
          { 'Content-Type': 'application/json' },
          { result: nil }
        ]
      end
      stubs.delete("#{Enginn::Client::BASE_URL}/projects/1/fakes/0") do |_|
        [
          503,
          { 'Content-Type': 'application/json' },
          { errors: { id: 'seriously, zero?' } }
        ]
      end
    end

    context 'when the request has succeeded' do
      let(:resource) { FakeResource.new(project, id: 42) }

      it 'returns true' do
        expect(resource.destroy!).to be true
      end
    end

    context 'when the request has failed' do
      let(:resource) { FakeResource.new(project, id: 0) }

      it 'raises an error' do
        expect { resource.destroy! }.to raise_error(Enginn::HTTPError)
      end
    end
  end

  describe '#destroy' do
    before do
      stubs.delete("#{Enginn::Client::BASE_URL}/projects/1/fakes/42") do |_|
        [
          200,
          { 'Content-Type': 'application/json' },
          { result: nil }
        ]
      end
      stubs.delete("#{Enginn::Client::BASE_URL}/projects/1/fakes/0") do |_|
        [
          503,
          { 'Content-Type': 'application/json' },
          { errors: { id: 'seriously, zero?' } }
        ]
      end
    end

    context 'when the request has succeeded' do
      let(:resource) { FakeResource.new(project, id: 42) }

      it 'returns true' do
        expect(resource.destroy).to be true
      end
    end

    context 'when the request has failed' do
      let(:resource) { FakeResource.new(project, id: 0) }

      it 'does not raise errors' do
        expect { resource.destroy }.not_to raise_error
      end

      it 'returns false' do
        expect(resource.destroy).to be false
      end

      it 'fill in #errors' do
        resource.destroy
        expect(resource.errors).not_to be_empty
      end
    end
  end

  describe '#inspect' do
    it 'returns a string' do
      expect(FakeResource.new(project).inspect).to be_a(String)
    end
  end
end
