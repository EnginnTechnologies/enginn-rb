# frozen_string_literal: true

module Enginn
  class Resource
    def self.path
      raise 'not implemented'
    end

    # def self.fetch(client, project, attributes)
    #   new(client, project, attributes).fetch!
    # end

    # def self.create(client, project, attributes)
    #   new(client, project, attributes).create!
    # end

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
      result = request(:patch)[:result]
      sync_attributes_with(result)
      self
    end

    def route
      "#{@project.route}/#{self.class.path}/#{@attributes[:id]}"
    end

    def inspect
      "#<#{self.class} #{@attributes.map { |name, value| "@#{name}=#{value}" }.join(', ')}>"
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
      response = @client.connection.public_send(method, route, @attributes)
      JSON.parse(JSON[response.body], symbolize_names: true)
    end
  end
end
