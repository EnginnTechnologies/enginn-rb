# frozen_string_literal: true

module Enginn
  # A Resource can be a Character, a Take, or anything described in the
  # Enginn API doc (https://app.enginn.tech/api/docs).
  #
  # A Resource depends on a Client that will be used for actual HTTP operations
  # and is relative to a parent Project (see {#initialize} parameters). When a
  # Resource is fetched through {#fetch!} or {#save!}, any received attributes
  # from the API is synced with the object such as it is available as an
  # instance method.
  #
  # @example
  #   character = Enginn::Character(client, project, { id: 42 })
  #   character.name # NoMethodError
  #   character.fetch!
  #   character.name # => 'Rocky'
  #
  # A Resource whose attributes include an ID will be considered as already
  # existing and as such, subsequent calls to {#save!} will issue a PATCH
  # request. Otherwise, a POST request will be issued instead, allowing the
  # creation of a new Resource.
  #
  # @example
  #   color = Enginn::Color.new(client, project, { code: '#16161D' })
  #   color.save! # POST request (i.e. a new color created)
  #   color.id # => 24
  #   color.name = 'Eigengrau'
  #   color.save! # PATCH request (i.e. the color is updated)
  #
  # @abstract Override the {.path} method to implement.
  class Resource
    # Get the path to use for this kind of {Enginn::Resource}
    #
    # @api private
    # @return [String]
    def self.path
      raise NotImplementedError
    end

    attr_reader :project
    attr_accessor :attributes

    # @param project [Enginn::Project] The parent project of this resource
    # @param attributes [Hash] The attributes to initialize the resource with
    def initialize(project, attributes = {})
      @project = project
      @attributes = {}
      sync_attributes_with(attributes || {})
    end

    # @raise [Faraday::Error] if something goes wrong during the request
    # @return [Enginn::Resource]
    def fetch!
      result = request(:get)[:result]
      sync_attributes_with(result)
      self
    end

    # @raise [Faraday::Error] if something goes wrong during the request
    # @return [Enginn::Resource]
    def save!
      response = request(@attributes[:id].nil? ? :post : :patch)
      sync_attributes_with(response[:result])
      self
    end

    # @raise [Faraday::Error] if something goes wrong during the request
    # @return [Enginn::Resource]
    def destroy!
      # TODO: find a way to properly notice the user that the deletion succeeded
      request(:delete)
      self
    end

    # @return [String]
    def inspect
      "#<#{self.class} #{@attributes.map { |name, value| "@#{name}=#{value.inspect}" }.join(', ')}>"
    end

    # @api private
    # @return [String]
    def route
      "#{@project.route}/#{self.class.path}/#{@attributes[:id]}"
    end

    private

    def sync_attributes_with(hash)
      @attributes.merge!(hash)
      @attributes.each do |attribute, value|
        instance_variable_set("@#{attribute}", value)
        self.class.define_method(attribute) { @attributes[attribute] }
        self.class.define_method("#{attribute}=") { |arg| @attributes[attribute] = arg }
      end
    end

    def request(method)
      resource_name = self.class.name.split('::').last.downcase
      params = %i[post patch].include?(method) ? { resource_name => @attributes } : {}
      response = @project.client.connection.public_send(method, route, params)
      JSON.parse(JSON[response.body], symbolize_names: true)
    end
  end
end
