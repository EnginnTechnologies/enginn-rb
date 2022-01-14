# frozen_string_literal: true

RSpec.describe Enginn::Client do
  let(:client) { described_class.new(api_token: '12345', adapter: :test) }

  describe '#connection' do
    context 'when a block is given' do
      it 'yields a Faraday::Connection object' do
        expect { |b| client.connection(&b) }.to yield_with_args(Faraday::Connection)
      end
    end

    context 'when no block is given' do
      it 'returns a Faraday::Connection object' do
        expect(client.connection).to be_a(Faraday::Connection)
      end
    end

    it 'initializes the connection with the right base URL' do
      expect(client.connection.url_prefix.to_s).to eq(described_class::BASE_URL)
    end
  end
end
