# frozen_string_literal: true

module Enginn
  class Character < Resource
    def self.path
      'characters'
    end

    # Retrieve the takes of this character.
    # @return [Enginn::TakesIndex]
    def takes
      TakesIndex.new(@project).where(character_id_eq: @attributes[:id])
    end
  end
end
