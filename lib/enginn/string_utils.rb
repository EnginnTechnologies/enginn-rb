# frozen_string_literal: true

module Enginn
  module StringUtils
    module_function

    def underscore(str)
      str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .tr('-', '_')
         .downcase
    end
  end
end
