module JSchema
  module Validator
    class AllOf < SimpleValidator
      private

      self.keywords = ['allOf']

      def validate_args(all_of)
        schema_array?(all_of, 'allOf') || invalid_schema('allOf', all_of)
      end

      def post_initialize(all_of)
        @all_of = all_of.map.with_index do |sch, index|
          Schema.build(sch, parent, "allOf/#{index}")
        end
      end

      def validate_instance(instance)
        valid = @all_of.all? do |schema|
          schema.valid?(instance)
        end

        unless valid
          "#{instance} must be valid against all the schemas"
        end
      end
    end
  end
end
