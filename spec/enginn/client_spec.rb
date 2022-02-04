# frozen_string_literal: true

RSpec.describe Enginn::Client do
  let(:client) { described_class.new(api_token: '12345', adapter: :test) }

  describe '#connection' do
    context 'when a block is given' do
      it 'yields a Faraday::Connection object' do
        expect { |b| client.connection(&b) }.to yield_with_args(Faraday::Connection)
      end
    end

    it 'returns a Faraday::Connection object' do
      expect(client.connection).to be_a(Faraday::Connection)
    end

    it 'initializes the connection with the right base URL' do
      expect(client.connection.url_prefix.to_s).to eq(described_class::BASE_URL)
    end
  end

  describe '#projects' do
    it 'returns a Enginn::ProjectsIndex instance' do
      expect(client.projects).to be_a(Enginn::ProjectsIndex)
    end

    it 'does not set any filters on the index' do
      expect(client.projects.filters).to be_empty
    end

    it 'does not make any request' do
      connection = client.connection
      allow(connection).to receive(:get)
      client.projects
      expect(connection).not_to have_received(:get)
    end
  end
end
