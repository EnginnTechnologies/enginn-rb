# frozen_string_literal: true

require_relative 'enginn/version'
require_relative 'enginn/client'

require_relative 'enginn/resource'
require_relative 'enginn/character'
require_relative 'enginn/take'
require_relative 'enginn/project'

require_relative 'enginn/resource_index'
require_relative 'enginn/characters_index'
require_relative 'enginn/takes_index'
require_relative 'enginn/projects_index'

module Enginn
  class Error < StandardError; end
end
