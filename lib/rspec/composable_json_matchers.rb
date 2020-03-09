# frozen_string_literal: true

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

      # @api private
      def json_value?(object)
        # value = false / null / true / object / array / number / string
        # https://www.rfc-editor.org/rfc/rfc8259.txt
        case object
        when Hash, Array, Numeric, String, TrueClass, FalseClass, NilClass
          true
        else
          false
        end
      end
    end

    # @api public
    #
    # Passes if actual string can be decoded as JSON and the decoded value passes the given
    # matcher. When a JSON value is given, it's handled as `be_json matching(value)`
    # (`matching` is an alias of the [`match`](http://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/match-matcher)
    # matcher).
    #
    # @param
    #   matcher_or_json_value
    #   [#matches?, Hash, Array, Numeric, String, TrueClass, FalseClass, NilClass]
    #   a matcher object or a JSON value
    #
    # @example
    #   expect('{ "foo": 1, "bar": 2 }').to be_json(foo: 1, bar: 2)
    #   expect('{ "foo": 1, "bar": 2 }').to be_json(foo: 1, bar: a_kind_of(Integer))
    #   expect('{ "foo": 1, "bar": 2 }').to be_json matching(foo: 1, bar: 2)
    #   expect('{ "foo": 1, "bar": 2 }').to be_json including(foo: 1)
    #   expect('{ "foo": 1, "bar": 2 }').to be_json a_kind_of(Hash)
    def be_json(matcher_or_json_value)
      if ComposableJSONMatchers.matcher?(matcher_or_json_value)
        BeJSON.new(matcher_or_json_value, ComposableJSONMatchers.configuration)
      elsif ComposableJSONMatchers.json_value?(matcher_or_json_value)
        matcher = matching(matcher_or_json_value)
        BeJSON.new(matcher, ComposableJSONMatchers.configuration)
      else
        raise ArgumentError, 'You must pass a matcher or a JSON value ' \
                             '(hash, array, numeric, string, true, false, or nil) ' \
                             'to `be_json` matcher.'
      end
    end
  end
end
