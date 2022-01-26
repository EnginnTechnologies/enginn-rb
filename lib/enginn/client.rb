# frozen_string_literal: true

require 'faraday'

module Enginn
  class Client
    BASE_URL = 'https://app.enginn.tech/api/v1'

    attr_reader :api_token, :adapter

    # Public: Create a new client.
    #
    # :api_token - The String API token to use for this client.
    # :adapter   - The Symbol Faraday adapter to use (default: Faraday.default_adapter)
    def initialize(api_token:, adapter: Faraday.default_adapter)
      @api_token = api_token
      @adapter = adapter
    end

    # Public: Get a Faraday connection to the API with relevant middlewares (authorization and JSON)
    #
    # If a block is given, yields the Faraday::Connection.
    #
    # Returns a Faraday::Connection.
    def connection
      @connection ||= Faraday.new(BASE_URL) do |conn|
        conn.request :authorization, 'Bearer', -> { @api_token }
        conn.request :json
        conn.response :json
        conn.response :logger
        conn.response :raise_error
      end
      block_given? ? yield(@connection) : @connection
    end

    def projects(arg = nil)
      case arg
      when String
        Project.new(self, { uid: arg })
      when Hash
        ProjectsIndex.new(self, arg)
      else
        ProjectsIndex.new(self)
      end
    end
  end
end
