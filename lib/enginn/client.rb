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
        conn.request :authorization, 'Bearer', -> { @api_token }
        conn.request :json
        conn.response :json
        conn.response :raise_error
      end
      yield(@connection) if block_given?
      @connection
    end

    # Retrieve one or multiple project(s).
    #
    # If no discriminant is given, return a {Enginn::ProjectsIndex} with no
    # filters. If a Hash is given, return a {Enginn::ProjectsIndex} filtered
    # with the given Hash.
    # If a String is given, return a {Enginn::Project} with its UID set as the
    # given String.
    #
    # @example
    #   client.projects # => Enginn::ProjectsIndex
    #   client.projects(name: 'New World') # => Enginn::ProjectsIndex
    #   client.projects('<uid>') # => Enginn::Project
    #
    # @param discriminant [nil, String, Hash]
    # @return [Enginn::Project, Enginn::ProjectsIndex]
    def projects(discriminant = nil)
      case discriminant
      when String
        Project.new(self, { uid: discriminant })
      when Hash
        ProjectsIndex.new(self, discriminant)
      else
        ProjectsIndex.new(self)
      end
    end
  end
end
