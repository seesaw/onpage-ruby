# frozen_string_literal: true

require_relative "resource"
require_relative "field"

module OnPage
  # OnPage::Schema
  class Schema
    attr_reader :id, :label, :langs, :resources

    def initialize(json = {})
      @id = json["id"]
      @label = json["label"]
      @langs = json["langs"]

      @resources = {}
      @resource_names = {}
      json["resources"].each do |json_resource|
        resource = Resource.new(json_resource)
        @resources[resource.id] = resource
        @resource_names[resource.name] = resource
      end
    end

    def resource(id_or_name)
      if id_or_name.instance_of? String
        @resource_names[id_or_name]
      else
        @resources[id_or_name]
      end
    end

    def ==(other)
      id == other.id
    end
  end
end
