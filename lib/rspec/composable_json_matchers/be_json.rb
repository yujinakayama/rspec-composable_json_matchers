require 'rspec/matchers'

module RSpec
  module ComposableJSONMatchers
    # @api private
    class BeJSON
      include RSpec::Matchers::Composable

      attr_reader :matcher, :configuration, :original_actual, :decoded_actual, :parser_error

      def initialize(matcher, configuration)
        @matcher = matcher
        @configuration = configuration
      end

      def matches?(actual)
        @original_actual = actual
        @decoded_actual = parse(original_actual)
        matcher.matches?(decoded_actual)
      rescue JSON::ParserError => error
        @parser_error = error
        false
      end

      def does_not_match?(actual)
        matched = matches?(actual)
        parser_error ? false : !matched
      end

      def description
        "be JSON #{matcher.description}"
      end

      def failure_message
        return parser_failure_message if parser_failure_message
        "expected #{original_actual} to be JSON #{matcher.description}"
      end

      def failure_message_when_negated
        return parser_failure_message if parser_failure_message
        "expected #{original_actual} not to be JSON #{matcher.description}"
      end

      def diffable?
        parser_error.nil? && matcher.diffable?
      end

      def expected
        matcher.expected
      end

      alias actual decoded_actual

      private

      def parse(json)
        require 'json'
        JSON.parse(json, configuration.parser_options)
      end

      def parser_failure_message
        return nil unless parser_error
        "cannot parse #{original_actual.inspect} as JSON: #{parser_error.message}"
      end
    end
  end
end
