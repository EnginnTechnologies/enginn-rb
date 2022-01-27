# frozen_string_literal: true

module Enginn
  class Project < Resource
    def self.path
      'projects'
    end

    def initialize(client, attributes = {})
      super(client, nil, attributes)
    end

    def characters(arg = nil)
      case arg
      when String
        Character.new(@client, self, { id: arg })
      when Hash
        CharactersIndex.new(@client, self, arg)
      else
        CharactersIndex.new(@client, self)
      end
    end

    def route
      # TODO: replace `uid` with `id` when PK migration is completed
      "#{self.class.path}/#{@attributes[:uid]}"
    end
  end
end
