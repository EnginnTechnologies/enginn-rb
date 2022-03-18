# frozen_string_literal: true

module Enginn
  class LineTag < Resource
    def self.path
      'line_tags'
    end

    # Retrieve the lines of this line tag.
    # @return [Enginn::LinesIndex]
    def lines
      LinesIndex.new(@project).where(line_tag_id_eq: @attributes[:id])
    end
  end
end
