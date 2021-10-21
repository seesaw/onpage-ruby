# frozen_string_literal: true

module OnPage
  # OnPage::Field
  class Field
    attr_reader :id, :name, :label, :labels, :is_multiple, :is_translatable, :type

    def initialize(json)
      @id = json["id"]
      @name = json["name"]
      @label = json["label"]
      @labels = json["labels"].to_a
      @is_multiple = json["is_multiple"]
      @is_translatable = json["is_translatable"]
      @type = json["type"]

      @rel_res_id = json["rel_res_id"]
      @rel_field_id = json["rel_field_id"]
    end

    def identifier(lang = nil)
      identifier = @name.dup
      if is_translatable
        lang ||= OnPage.schema.langs.first
        identifier += "_#{lang}"
      end
      identifier
    end

    def related_resource
      throw StandardException.new("Field #{name} has no related resource") unless @rel_res_id
      OnPage.schema.resource(@rel_res_id)
    end

    def related_field
      related_resource.field(@rel_field_id)
    end

    def ==(other)
      id == other.id
    end
  end
end
