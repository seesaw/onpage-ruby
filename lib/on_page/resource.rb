# frozen_string_literal: true

require_relative "field"

module OnPage
  # OnPage::Resource
  class Resource
    attr_reader :id, :name, :label, :labels, :fields

    def initialize(json)
      @id = json["id"]
      @name = json["name"]
      @label = json["label"]
      @labels = json["labels"].to_a

      @fields = {}
      @field_names = {}
      json["fields"].each do |json_field|
        field = Field.new(json_field)
        @fields[field.id] = field
        @field_names[field.name] = field
      end
    end

    def field(id_or_name)
      if id_or_name.instance_of? String
        @field_names[id_or_name]
      else
        @fields[id_or_name]
      end
    end

    def ==(other)
      id == other.id
    end
  end
end
