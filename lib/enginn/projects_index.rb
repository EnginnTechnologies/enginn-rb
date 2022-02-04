# frozen_string_literal: true

module Enginn
  class ProjectsIndex < ResourceIndex
    # @see ResourceIndex.resource
    def self.resource
      Project
    end

    attr_reader :client

    # @param client [Enginn::Client] The client to use with this project and resources
    def initialize(client)
      @client = client
      super(self)
    end

    # @see ResourceIndex#fetch!
    def fetch!
      response = request
      @pagination = response[:pagination]
      @collection = response[:result].map do |attributes|
        self.class.resource.new(@client, attributes)
      end
      self
    end

    # @api private
    def route
      'projects'
    end
  end
end
