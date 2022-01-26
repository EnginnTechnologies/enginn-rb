# frozen_string_literal: true

module Enginn
  class ProjectsIndex
    include Enumerable

    def initialize(client, filters = {})
      @client = client
      @filters = filters || {}
      @pagination = { current: 1 }
    end

    def each(&block)
      fetch! if @pagination[:last].nil? || @pagination[:current] <= @pagination[:last]
      @collection.each(&block)
    end

    def page(page)
      @pagination[:current] = page
      self
    end

    def per(per)
      @pagination[:per] = per
      self
    end

    def filters(filters)
      @filters = filters || {}
      self
    end

    def fetch!
      pagination = "per=#{@pagination[:per]}&page=#{@pagination[:current]}"
      filters = @filters.map { |filter, val| "q[#{filter}]=#{val}" }.join('&')
      response = @client.connection.get("projects?#{pagination}&#{filters}")
      body = JSON.parse(JSON[response.body], symbolize_names: true)

      @pagination = body[:pagination]
      @collection = body[:result].map { |attributes| Project.new(@client, attributes) }

      self
    end

    def inspect
      attributes = instance_variables.map do |var|
        "#{var}=#{instance_variable_get(var)}"
      end
      "#<#{self.class} #{attributes.join(', ')}>"
    end
  end
end
