# frozen_string_literal: true

module Enginn
  class Project
    def initialize(client, attributes = {})
      @client = client
      @attributes = {}
      sync_attributes_with(attributes)
    end

    def characters(arg = nil)
      case arg
      when String
        Character.new(@client, self, { id: arg })
      when Hash
        CharactersIndex.new(@client, self, arg)
      else
        CharactersIndex.new(@client, self)
      end
    end

    def route
      "projects/#{@attributes[:uid]}"
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
      response = @client.connection.public_send(method, "projects/#{@attributes[:uid]}")
      JSON.parse(JSON[response.body], symbolize_names: true)
    end
  end
end
