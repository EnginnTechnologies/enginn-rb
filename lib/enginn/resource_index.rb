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
  # issued when the end of a page is reached.
  # One can also force fetching manually using {#fetch!}.
  #
  # @example
  #   characters = project.characters.where(scene_id: '12345').per(50)
  #   characters.map(&:name)
  #
  # @abstract Override the {.resource} method to implement.
  class ResourceIndex
    # Define the type of {Enginn::Resource} to use with this kind of {Enginn::ResourceIndex}.
    #
    # @api private
    # @return [Enginn::Resource]
    def self.resource
      raise NotImplementedError # REVIEW: not sure this is intended to be directly used...
    end

    # @api private
    # @return [String]
    def self.path
      resource.path
    end

    include Enumerable

    attr_reader :client, :project, :filters, :pagination

    # @param client [Enginn::Client] The client to use
    # @param project [Enginn::Project] The parent project of the indexed resource
    # @param filters [Hash, nil] An optional Hash of filters (see {#where})
    # TODO: remove `filters` from constructor to enforce consistency and use of #where
    def initialize(client, project, filters = nil)
      @client = client
      @project = project
      @filters = filters || {}
      @pagination = { current: 1 }
    end

    # @yieldparam item [Enginn::Resource]
    def each(&block)
      fetch! if @pagination[:last].nil? || @pagination[:current] < @pagination[:last]
      @collection.each(&block)
    end

    # @param page [Integer] The page number
    # @return [Enginn::ResourceIndex]
    def page(page)
      @pagination[:current] = page
      self
    end

    # @param per [Integer] The number of items per page
    # @return [Enginn::ResourceIndex]
    def per(per)
      @pagination[:per] = per
      self
    end

    # @param filters [Hash] Filters as you would use them in the `q` object with the API.
    # @return [Enginn::ResourceIndex]
    def where(filters)
      @filters.merge!(filters || {})
      self
    end

    # @return [Enginn::ResourceIndex]
    def fetch!
      response = request
      @pagination = response[:pagination]
      @collection = response[:result].map do |attributes|
        self.class.resource.new(@client, @project, attributes)
      end
      self
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
      response = @client.connection.get(route, {
        per: @pagination[:per],
        page: @pagination[:page],
        q: @filters
      })
      JSON.parse(JSON[response.body], symbolize_names: true)
    end
  end
end
