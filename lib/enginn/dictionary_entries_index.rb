# frozen_string_literal: true

module Enginn
  class DictionaryEntriesIndex < ResourceIndex
    def self.resource
      DictionaryEntry
    end
  end
end
