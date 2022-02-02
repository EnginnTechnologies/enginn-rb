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

    # Retrieve one or multiple characters(s).
    #
    # If no discriminant is given, return a {Enginn::CharactersIndex} with no
    # filters. If a Hash is given, return a {Enginn::CharactersIndex} filtered
    # with the given Hash.
    # If a String is given, return a {Enginn::Character} with its ID set as the
    # given String.
    #
    # @param discriminant [nil, String, Hash]
    # @return [Enginn::Character, Enginn::CharactersIndex]
    def characters(discriminant = nil)
      case discriminant
      when String
        Character.new(self, { id: discriminant })
      when Hash
        CharactersIndex.new(self, discriminant)
      else
        CharactersIndex.new(self)
      end
    end

    # Retrieve one or multiple takes(s).
    #
    # If no discriminant is given, return a {Enginn::TakesIndex} with no
    # filters. If a Hash is given, return a {Enginn::TakesIndex} filtered
    # with the given Hash.
    # If a String is given, return a {Enginn::Take} with its ID set as the
    # given String.
    #
    # @param discriminant [nil, String, Hash]
    # @return [Enginn::Take, Enginn::TakesIndex]
    def takes(discriminant = nil)
      case discriminant
      when String
        Take.new(self, { id: discriminant })
      when Hash
        TakesIndex.new(self, discriminant)
      else
        TakesIndex.new(self)
      end
    end

    # @api private
    def route
      # TODO: replace `uid` with `id` when PK migration is completed
      "#{self.class.path}/#{@attributes[:uid]}"
    end
  end
end
