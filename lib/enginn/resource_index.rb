# frozen_string_literal: true

module Enginn
  # A {ResourceIndex} is a collection of fetchable {Resource}.
  #
  # It can be filtered and paginated through the chainable methods {#per},
  # {#page}, and {#where}. It also includes the Enumerable module so methods
  # such as {#each}, #map or #to_a are available.
  #
  # Actual API requests are only issued when the {#each} method (or any method
  # from Enumerable) is called. While {#each}-ing, new API request will be
  # issued when the end of a page is reached. Note that when using {#page}, only
  # the given page is reached for.
  # One can also force fetching manually using {#fetch}.
  #
  # @example
  #   takes = project.takes.where(synthesis_text_cont: 'hello')
  #   takes.map(&:character_name)
  #
  # @abstract Override the {.resource} method to implement.
  class ResourceIndex
    # Define the type of {Enginn::Resource} to use with this kind of {Enginn::ResourceIndex}.
    #
    # @api private
    # @return [Enginn::Resource]
    def self.resource
      raise "resource is not overriden for #{self}"
    end

    # @api private
    # @return [String]
    def self.path
      resource.path
    end

    include Enumerable

    attr_reader :project, :errors
    attr_accessor :filters, :pagination

    # @param project [Enginn::Project] The parent project of the indexed resource
    def initialize(project)
      @project = project
      @filters = {}
      @pagination = { current: 1 }
      @errors = []
    end

    # @yieldparam item [Enginn::Resource]
    # @return [self]
    def each(&block)
      fetch!
      @collection.each(&block)
      return self if @pagination[:locked]

      while @pagination[:current] < @pagination[:last]
        pagination[:current] += 1
        fetch!
        @collection.each(&block)
      end

      @pagination = { current: 1 }
      self
    end

    # @param page [Integer] The page number
    # @return [Enginn::ResourceIndex] A new index with updated pagination
    def page(page)
      new_index = clone
      new_index.pagination = @pagination.merge(current: page, locked: true)
      new_index
    end

    # @param per [Integer] The number of items per page
    # @return [Enginn::ResourceIndex] A new index with updated pagination
    def per(per)
      new_index = clone
      new_index.pagination = @pagination.merge(per: per)
      new_index
    end

    # @param filters [Hash] Filters as you would use them in the `q` object with the API.
    # @return [Enginn::ResourceIndex] A new filtered index
    def where(filters)
      new_index = clone
      new_index.filters = @filters.merge(filters || {})
      new_index
    end

    # Fetch the current page from the API. Resulting items of the collection are
    # wrapped in the corresponding {Enginn::Resource} subclass.
    #
    # @return [true] if the request has been successfull
    def fetch!
      response = request
      @pagination = response[:pagination]
      @collection = response[:result].map do |attributes|
        self.class.resource.new(@project, attributes)
      end
      true
    end

    # Same as {#fetch!} but return false instead of raising an exception.
    # Also fill in {#errors} with the server response.
    # @see fetch!
    # @return [Boolean]
    def fetch
      fetch!
      true
    rescue Faraday::Error => e
      @errors << e.response
      false
    end

    # @return [String]
    def inspect
      attributes = instance_variables.map do |var|
        "#{var}=#{instance_variable_get(var)}"
      end
      "#<#{self.class} #{attributes.join(', ')}>"
    end

    # @api private
    # @return [String]
    def route
      "#{@project.route}/#{self.class.path}"
    end

    private

    def request
      response = @project.client.connection.get(route, {
        per: @pagination[:per],
        page: @pagination[:current],
        q: @filters
      }.reject { |_, value| value.nil? || (value.respond_to?(:empty?) && value.empty?) })
      JSON.parse(JSON[response.body], symbolize_names: true)
    end
  end
end
