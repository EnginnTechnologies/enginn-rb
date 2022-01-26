# frozen_string_literal: true

module Enginn
  class ResourceIndex
    def self.resource
      raise 'not implemented'
    end

    def self.path
      resource.path
    end

    include Enumerable

    def initialize(client, project, filters = {})
      @client = client
      @project = project
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

    def route
      "#{@project.route}/#{self.class.path}"
    end

    def fetch!
      response = request
      @pagination = response[:pagination]
      @collection = response[:result].map do |attributes|
        self.class.resource.new(@client, @project, attributes)
      end
      self
    end

    def inspect
      attributes = instance_variables.map do |var|
        "#{var}=#{instance_variable_get(var)}"
      end
      "#<#{self.class} #{attributes.join(', ')}>"
    end

    private

    def request
      pagination = "per=#{@pagination[:per]}&page=#{@pagination[:current]}"
      filters = @filters.map { |filter, val| "q[#{filter}]=#{val}" }.join('&')
      response = @client.connection.get("#{route}?#{pagination}&#{filters}")
      JSON.parse(JSON[response.body], symbolize_names: true)
    end
  end
end
