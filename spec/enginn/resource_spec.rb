# frozen_string_literal: true

class FakeResource < Enginn::Resource
  def self.path
    'fakes'
  end
end

RSpec.describe Enginn::Resource do
  let(:client) { Enginn::Client.new(api_token: '12345') }
  let(:project) { Enginn::Project.new(client, id: 1) }

  before do
    client.connection do |conn|
      conn.adapter :test do |stub|
        stub.get("#{Enginn::Client::BASE_URL}/projects/1") do |_|
          [
            200,
            { 'Content-Type': 'application/json' },
            { result: { id: 1, name: 'Fake Project' } }
          ]
        end
        stub.get("#{Enginn::Client::BASE_URL}/projects/1/fakes/42") do |_|
          [
            200,
            { 'Content-Type': 'application/json' },
            { result: { id: 42, name: 'Fake' } }
          ]
        end
        stub.post("#{Enginn::Client::BASE_URL}/projects/1/fakes/") do |env|
          [
            201,
            { 'Content-Type': 'application/json' },
            { result: JSON.parse(env.body).merge(id: 42) }
          ]
        end
        stub.patch("#{Enginn::Client::BASE_URL}/projects/1/fakes/42") do |env|
          [
            200,
            { 'Content-Type': 'application/json' },
            { result: JSON.parse(env.body).merge(id: 42) }
          ]
        end
        stub.delete("#{Enginn::Client::BASE_URL}/projects/1/fakes/42") do |_|
          [
            200,
            { 'Content-Type': 'application/json' },
            { result: nil }
          ]
        end
      end
    end
  end

  after do
    Faraday.default_connection = nil
  end

  describe '#fetch!' do
    let(:resource) { FakeResource.new(project, { id: 42 }) }

    before { resource.fetch! }

    it 'synchronizes attributes' do
      expect(resource.attributes).to include({ id: 42, name: 'Fake' })
    end

    it 'exposes attributes as instance methods' do
      resource.attributes.each_key do |attr|
        expect { resource.send(attr) }.not_to raise_error
      end
    end
  end

  describe '#save!' do
    context 'when the resource has no ID' do
      let(:resource) { FakeResource.new(project, { name: 'Fake' }) }

      before { resource.save! }

      it 'creates a new resource' do
        expect(resource.id).to eq(42)
      end
    end

    context 'when the resource has an ID' do
      let(:resource) { FakeResource.new(project, { id: 42, name: 'Fake' }) }

      before do
        resource.name = 'New Name'
        resource.save!
      end

      it 'updates the resource' do
        expect(resource.name).to eq('New Name')
      end
    end
  end

  describe '#destroy!' do
    pending 'How do we test/show resource destruction?'

    # it 'deletes the resource' do
    #   raise StandardError
    # end
  end

  describe '#inspect' do
    it 'returns a string' do
      expect(FakeResource.new(project).inspect).to be_a(String)
    end
  end
end
