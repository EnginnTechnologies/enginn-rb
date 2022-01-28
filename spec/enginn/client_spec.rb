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
    context 'when no argument is given' do
      it 'returns a Enginn::ProjectsIndex instance' do
        expect(client.projects).to be_a(Enginn::ProjectsIndex)
      end

      it 'does not set any filters on the index' do
        expect(client.projects.filters).to be_empty
      end
    end

    context 'when the argument is a Hash' do
      it 'returns a Enginn::ProjectsIndex instance' do
        expect(client.projects(name: 'Buzz')).to be_a(Enginn::ProjectsIndex)
      end

      it 'filters the index' do
        expect(client.projects(name: 'Buzz').filters).to eq(name: 'Buzz')
      end
    end

    context 'when the argument is a String' do
      it 'returns a Enginn::Project instance' do
        expect(client.projects('12345')).to be_a(Enginn::Project)
      end

      it 'sets the correct uid' do
        expect(client.projects('12345').uid).to eq('12345')
      end
    end
  end
end
