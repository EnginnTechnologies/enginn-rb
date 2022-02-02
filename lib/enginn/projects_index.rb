# frozen_string_literal: true

module Enginn
  class ProjectsIndex < ResourceIndex
    def self.resource
      Project
    end

    attr_reader :client

    # @param client [Enginn::Client] The client to use with this project and resources
    def initialize(client)
      @client = client
      super(self)
    end

    def route
      'projects'
    end

    def fetch!
      response = request
      @pagination = response[:pagination]
      @collection = response[:result].map do |attributes|
        self.class.resource.new(@client, attributes)
      end
      self
    end
  end
end
