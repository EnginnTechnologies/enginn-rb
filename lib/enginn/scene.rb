# frozen_string_literal: true

module Enginn
  class Scene < Resource
    def self.path
      'scenes'
    end

    # Retrieve the lines of this scene.
    # @return [Enginn::TakesIndex]
    def lines
      LinesIndex.new(@project).where(scene_id_eq: @attributes[:id])
    end
  end
end
