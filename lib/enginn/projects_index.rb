# frozen_string_literal: true

module Enginn
  class ProjectsIndex < ResourceIndex
    def self.resource
      Project
    end

    def initialize(client, filters = nil)
      super(client, nil, filters)
    end

    def route
      'projects'
    end

    # HACK: needed to override the way individual resources are initialized
    # because Project#initiliaze only take 2 arguments.
    # REVIEW: Should we use keywords arguments for Resource#initiliaze instead ?
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
