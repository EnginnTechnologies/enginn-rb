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
  #   color.save! # POST request / new color created
  #   color.id # => 24
  #   color.name = 'Eigengrau'
  #   color.save! # PATCH request / the color is updated
  class Resource
    attr_reader :client, :project
    attr_accessor :attributes

    # @param client [Enginn::Client] The client that will be used for this resource
    # @param project [Enginn::Project] The parent project of this resource
    # @param attributes [Hash] The attributes to initialize the resource with
    def initialize(client, project, attributes = {})
      @client = client
      @project = project
      @attributes = {}
      sync_attributes_with(attributes)
    end

    def fetch!
      result = request(:get)[:result]
      sync_attributes_with(result)
      self
    end

    def save!
      response = request(@attributes[:id].nil? ? :post : :patch)
      sync_attributes_with(response[:result])
      self
    end

    def destroy!
      request(:delete)
      self
    end

    def route
      "#{@project.route}/#{self.class.path}/#{@attributes[:id]}"
    end

    def inspect
      "#<#{self.class} #{@attributes.map { |name, value| "@#{name}=#{value.inspect}" }.join(', ')}>"
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
      params = %i[post patch].include?(method) ? @attributes : {}
      response = @client.connection.public_send(method, route, params)
      JSON.parse(JSON[response.body], symbolize_names: true)
    end
  end
end
