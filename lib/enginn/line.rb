# frozen_string_literal: true

module Enginn
  class Line < Resource
    def self.path
      'lines'
    end

    # Retrieve the takes of this line.
    # @return [Enginn::TakesIndex]
    def takes
      TakesIndex.new(@project).where(line_id_eq: @attributes[:id])
    end
  end
end
