# frozen_string_literal: true

module Enginn
  class Resource
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
