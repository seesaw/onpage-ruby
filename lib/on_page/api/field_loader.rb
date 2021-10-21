# frozen_string_literal: true

module OnPage
  module Api
    # OnPage::Api::FieldLoader
    class FieldLoader
      def initialize(relation = nil)
        @relation = relation
        @fields = ["+"]
        @relations = {}
      end

      def add_relation(name)
        @relations[name] ||= FieldLoader.new(name)
      end

      def encode
        encoded = @fields
        @relations.values do |relation|
          encoded << relation.encode
        end
        encoded = [@relation, encoded] unless @relation.nil?
        encoded
      end
    end
  end
end
