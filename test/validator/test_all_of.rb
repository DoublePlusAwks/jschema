require 'minitest/autorun'
require 'jschema'

require_relative 'assertions'
require_relative 'schema_validation_helpers'
require_relative 'validation_against_schemata_tests'

class TestAllOf < MiniTest::Unit::TestCase
  include Assertions
  include SchemaValidationHelpers
  include ValidationAgainstSchemataTests

  def test_passing_validation_against_schemata
    stub_schema_validations(true, true) do
      assert validator([generate_schema, generate_schema]).valid?('test')
    end
  end

  def test_failing_validation_against_schemata
    stub_schema_validations(false, true) do
      refute validator([generate_schema, generate_schema]).valid?('test')
    end
  end

  private

  def validator_class
    JSchema::Validator::AllOf
  end
end
