require 'rspec/composable_json_matchers/be_json'
require 'rspec/composable_json_matchers/configuration'
require 'rspec/composable_json_matchers/version'

module RSpec
  module ComposableJSONMatchers
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield configuration
      end

      def reset!
        @configuration = nil
      end

      def matcher?(object)
        begin
          return false if object.respond_to?(:i_respond_to_everything_so_im_not_really_a_matcher)
        rescue NoMethodError
          return false
        end

        object.respond_to?(:matches?)
      end
    end

    def be_json(matcher_or_structure)
      if Hash === matcher_or_structure || Array === matcher_or_structure
        matcher = matching(matcher_or_structure)
        BeJSON.new(matcher, ComposableJSONMatchers.configuration)
      elsif ComposableJSONMatchers.matcher?(matcher_or_structure)
        BeJSON.new(matcher_or_structure, ComposableJSONMatchers.configuration)
      else
        raise ArgumentError, 'You must pass a matcher, a hash, or an array to `be_json` matcher.'
      end
    end
  end
end
