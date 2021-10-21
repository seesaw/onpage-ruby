# frozen_string_literal: true

require_relative "downloadable"

module OnPage
  # OnPage::Thing
  class Thing
    attr_reader :id

    def initialize(thing_hash = {})
      @id = thing_hash["id"]
      @relations = {}
      thing_hash["relations"]&.each_pair do |field_name, related_things|
        key = resource.field(field_name)
        things = related_things.map { |thing| Thing.new(thing) }
        add_relation(key, things)
      end
      @resource_id = thing_hash["resource_id"]
      @fields = thing_hash["fields"]
    end

    def val(field_name, lang = nil)
      field = resolve_field(field_name)
      codename = field.identifier(lang)
      default = field.is_multiple ? [] : nil
      values = @fields[codename]
      return default if values.nil?

      values = [values] unless field.is_multiple

      values = values.map { |attributes| Downloadable.new(attributes) } if %w[file image].include? field.type

      field.is_multiple ? values : values.first
    end

    def rel(path)
      path = path.split(".") if path.is_a? String
      field_name = path.shift # removes first element
      field = resolve_field(field_name)
      codename = field.identifier

      unless @relations[codename]
        with = []
        with << path.join(".") unless path.empty?
        load_relation(field, with)
      end
      relation = @relations[codename]

      unless path.empty?
        relation = relation.map { |related| related.rel(path) }
                           .flatten
                           .map(&:id)
                           .uniq
      end
      relation
    end

    def resolve_field(field_name)
      field = resource.field(field_name)
      throw FieldNotFound.new("Cannot find field '#{field_name}'") unless field
      field
    end

    def load_relation(field, with = [])
      criteria = OnPage::Api::Criteria.new(field.related_resource.name)
                                      .related_to(field, id)
                                      .with(with)
                                      .all
      result = OnPage::Api.query(criteria)
      add_relation(field, result)
    end

    def resource
      OnPage.schema.resource(@resource_id)
    end

    def ==(other)
      id == other.id
    end

    private

    def add_relation(field, things)
      @relations[field.identifier] = things
    end
  end
end
