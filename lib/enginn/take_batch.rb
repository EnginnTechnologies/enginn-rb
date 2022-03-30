# frozen_string_literal: true

module Enginn
  class TakeBatch < Resource
    def self.path
      'take_batches'
    end

    # Retrieve the takes of this take_batch.
    # @return [Enginn::TakesIndex]
    def takes
      TakesIndex.new(@project).where(take_batch_id_eq: @attributes[:id])
    end
  end
end
