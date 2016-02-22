module RSpec
  module ComposableJSONMatchers
    class Configuration
      # @api public
      #
      # The default value of .parser_options.
      #
      # @see #parser_options
      DEFAULT_PARSER_OPTIONS = { symbolize_names: true }.freeze

      # @api public
      #
      # Returns the current options for JSON.parse used in the `be_json` matcher.
      #
      # @return [Hash] the current options for JSON.parse.
      #
      # @see #parser_options=
      # @see http://ruby-doc.org/stdlib-2.3.0/libdoc/json/rdoc/JSON.html#method-i-parse
      def parser_options
        @parser_options ||= DEFAULT_PARSER_OPTIONS
      end

      # @api public
      #
      # Set the given hash as the option for JSON.parse used in the `be_json` matcher.
      #
      # @param hash [Hash] an option for JSON.parse
      #
      # @return [void]
      #
      # @see #parser_options
      # @see http://ruby-doc.org/stdlib-2.3.0/libdoc/json/rdoc/JSON.html#method-i-parse
      def parser_options=(hash)
        raise ArgumentError, 'You must pass a hash to `parser_options=`.' unless hash.is_a?(Hash)
        @parser_options = hash
      end
    end
  end
end
