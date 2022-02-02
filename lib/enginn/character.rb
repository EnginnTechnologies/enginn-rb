# frozen_string_literal: true

module Enginn
  class Character < Resource
    def self.path
      'characters'
    end

    # Retrieve one or multiple takes(s) of this character.
    #
    # If no discriminant is given, return a {Enginn::TakesIndex} with no
    # filters. If a Hash is given, return a {Enginn::TakesIndex} filtered
    # with the given Hash.
    # If a String is given, return a {Enginn::Take} with its ID set as the
    # given String.
    #
    # @param discriminant [nil, String, Hash]
    # @return [Enginn::Take, Enginn::TakesIndex]
    def takes(arg = nil)
      case arg
      when String
        Take.new(@project, { id: arg }.merge(character_id_eq: @attributes[:id]))
      when Hash
        TakesIndex.new(@project).where(arg.merge(character_id_eq: @attributes[:id]))
      else
        TakesIndex.new(@project).where(character_id_eq: @attributes[:id])
      end
    end
  end
end
