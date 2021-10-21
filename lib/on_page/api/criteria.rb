# frozen_string_literal: true

require_relative "field_loader"

module OnPage
  module Api
    # OnPage::Api::Criteria
    class Criteria
      attr_reader :resource

      def initialize(resource)
        @resource = resource
        @field_loader = FieldLoader.new
        @result_type = "list"
        @offset = @limit = @related_to = nil
        @filters = []
        @options = {
          no_labels: true,
          hyper_compact: true,
          use_field_names: true
        }
      end

      def all
        @result_type = "list"
        self
      end

      def paginate
        @result_type = "paginate"
        self
      end

      def first
        @result_type = "first"
        self
      end

      def with(relations)
        relations = [relations] if relations.is_a? String
        relations.each do |relation|
          path = relation.split(".")
          loader = @field_loader
          path.each { |name| loader = loader.add_relation(name) }
        end
        self
      end

      def offset(offset)
        @offset = offset
        self
      end

      def limit(limit)
        @limit = limit
        self
      end

      def related_to(field, thing_id)
        @related_to = {
          field_id: field.id,
          thing_id: thing_id
        }
        self
      end

      # usage example:
      #   .where("chapter", "2nd")
      #   .where("createion_date", ">=", "2021-9-2")
      def where(field_name, operator_or_value, value = nil)
        if value.nil?
          value = operator_or_value
          operator_or_value = "="
        end
        @filters << [field_name, operator_or_value, value]
        self
      end

      def options(options)
        @options.merge! options if options
        self
      end

      def to_h
        criteria = {
          resource: @resource,
          fields: @field_loader.encode,
          return: @result_type.to_s
        }
        criteria["options"] = @options unless @options.empty?
        criteria["filters"] = @filters unless @filters.empty?
        criteria["related_to"] = @related_to if @related_to
        criteria["limit"] = @limit if @limit
        criteria["offset"] = @offset if @offset

        criteria
      end
    end
  end
end
