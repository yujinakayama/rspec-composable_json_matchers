require 'rspec/composable_json_matchers/be_json'
require 'rspec/composable_json_matchers/configuration'
require 'rspec/composable_json_matchers/version'

module RSpec
  # Mix-in module for the `be_json` matcher.
  #
  # @example Make `be_json` matcher available everywhere
  #   # spec/spec_helper.rb
  #   require 'rspec/composable_json_matchers'
  #   RSpec.configure do |config|
  #     include RSpec::ComposableJSONMatchers
  #   end
  #
  # @example Make `be_json` matcher available only in specific example groups
  #   require 'rspec/composable_json_matchers'
  #   describe 'something' do
  #     include RSpec::ComposableJSONMatchers
  #   end
  module ComposableJSONMatchers
    class << self
      # @api public
      #
      # Returns the current configuration.
      #
      # @return [RSpec::ComposableJSONMatchers::Configuration] the current configuration
      #
      # @see .configure
      def configuration
        @configuration ||= Configuration.new
      end

      # @api public
      #
      # Provides a block for configuring RSpec::ComposableJSONMatchers.
      #
      # @yieldparam config [RSpec::ComposableJSONMatchers::Configuration] the current configuration
      #
      # @return [void]
      #
      # @example
      #   # spec/spec_helper.rb
      #   RSpec::ComposableJSONMatchers.configure do |config|
      #     config.parser_options = { symbolize_names: false }
      #   end
      #
      # @see .configuration
      def configure
        yield configuration
      end

      # @api private
      def reset!
        @configuration = nil
      end

      # @api private
      def matcher?(object)
        begin
          return false if object.respond_to?(:i_respond_to_everything_so_im_not_really_a_matcher)
        rescue NoMethodError
          return false
        end

        object.respond_to?(:matches?)
      end
    end

    # @api public
    #
    # Passes if actual string can be decoded as JSON and the decoded structure passes the given
    # matcher. When a hash is given, it's handled as `be_json matching(hash)` (`matching` is an
    # alias of the [`match`](http://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/match-matcher)
    # matcher).
    #
    # @param matcher_or_structure [#matches?, Hash, Array] a matcher object, a hash, or an array
    #
    # @example
    #   expect('{ "foo": 1, "bar": 2 }').to be_json(foo: 1, bar: 2)
    #   expect('{ "foo": 1, "bar": 2 }').to be_json(foo: 1, bar: a_kind_of(Integer))
    #   expect('{ "foo": 1, "bar": 2 }').to be_json matching(foo: 1, bar: 2)
    #   expect('{ "foo": 1, "bar": 2 }').to be_json including(foo: 1)
    #   expect('{ "foo": 1, "bar": 2 }').to be_json a_kind_of(Hash)
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
