# frozen_string_literal: true

require 'faraday'

module Enginn
  class Client
    BASE_URL = 'https://app.enginn.tech/api/v1'

    attr_reader :api_token, :adapter

    # @param api_token [String] The API token to use
    # @param adapter [Symbol] The Faraday adapter to use
    def initialize(api_token:, adapter: Faraday.default_adapter)
      @api_token = api_token
      @adapter = adapter
    end

    # Get a connection to the API.
    #
    # @yieldparam connection [Faraday::Connection] if a block is given
    # @return [Faraday::Connection]
    def connection
      @connection ||= Faraday.new(BASE_URL) do |conn|
        conn.adapter @adapter
        conn.request :authorization, 'Bearer', -> { @api_token }
        conn.request :json
        conn.response :json
        conn.response :raise_error
      end
      yield(@connection) if block_given?
      @connection
    end

    # Retrieve the projects the account have access to.
    #
    # @return [Enginn::ProjectsIndex]
    def projects
      ProjectsIndex.new(self)
    end
  end
end
