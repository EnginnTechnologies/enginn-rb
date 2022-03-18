# frozen_string_literal: true

module Enginn
  class Project < Resource
    def self.path
      'projects'
    end

    attr_reader :client

    # @param client [Enginn::Client] The client to use with this project and its sub-resources
    def initialize(client, attributes = {})
      @client = client
      super(self, attributes)
    end

    # Retrieve the characters present in this project.
    # @return [Enginn::CharactersIndex]
    def characters
      CharactersIndex.new(self)
    end

    # Retrieve the line_tags present in this project.
    # @return [Enginn::LineTagsIndex]
    def line_tags
      LineTagsIndex.new(self)
    end

    # Retrieve the takes present in this project.
    # @return [Enginn::TakesIndex]
    def takes
      TakesIndex.new(self)
    end

    # @api private
    def route
      "#{self.class.path}/#{@attributes[:id]}"
    end
  end
end
