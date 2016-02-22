module RSpec
  module ComposableJSONMatchers
    class Configuration
      DEFAULT_PARSER_OPTIONS = { symbolize_names: true }.freeze

      def parser_options
        @parser_options ||= DEFAULT_PARSER_OPTIONS
      end

      def parser_options=(hash)
        raise ArgumentError, 'You must pass a hash to `parser_options=`.' unless hash.is_a?(Hash)
        @parser_options = hash
      end
    end
  end
end
