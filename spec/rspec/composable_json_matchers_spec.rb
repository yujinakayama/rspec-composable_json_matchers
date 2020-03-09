# frozen_string_literal: true

require 'json'

RSpec.describe '#be_json matcher' do
  subject(:matcher) do
    be_json(arg)
  end

  let(:actual_json) do
    actual_original.to_json
  end

  let(:actual_original) do
    {
      foo: 1,
      bar: 2
    }
  end

  def by_rescuing_expectation_failure
    yield
  rescue RSpec::Expectations::ExpectationNotMetError
  end

  shared_context 'with positive expectation', :positive do
    let(:expectation) do
      expect(actual_json).to matcher
    end
  end

  shared_context 'with negative expectation', :negative do
    let(:expectation) do
      expect(actual_json).not_to matcher
    end
  end

  shared_examples 'passes' do
    it 'passes' do
      expectation
    end
  end

  shared_examples 'fails' do |failure_messages|
    failure_messages = Array(failure_messages)

    it 'fails' do
      expect { expectation }.to fail_including(*failure_messages)
    end
  end

  shared_examples 'is diffable' do
    it { should be_diffable }

    it 'provides the expected structure as #expected' do
      expect(matcher.expected).to eq(expected_structure)
    end

    it 'provides the decoded actual as #actual' do
      by_rescuing_expectation_failure { expectation }
      expect(matcher.actual).to eq(actual_original)
    end
  end

  shared_examples 'is not diffable' do
    it 'is not diffable' do
      by_rescuing_expectation_failure { expectation }
      expect(matcher).not_to be_diffable
    end
  end

  context 'with a hash' do
    let(:arg) do
      {
        foo: 1,
        bar: a_truthy_value
      }
    end

    it 'provides description "be JSON matching EXPECTED"' do
      expect(matcher.description).to eq('be JSON matching {:foo=>1, :bar=>(a truthy value)}')
    end

    context 'when the decoded actual matches the hash' do
      let(:actual_original) do
        {
          foo: 1,
          bar: 2
        }
      end

      context 'with positive expectation', :positive do
        include_examples 'passes'
      end

      context 'with negative expectation', :negative do
        include_examples 'fails', 'expected {"foo":1,"bar":2} not to be JSON matching ' \
                                  '{:foo=>1, :bar=>(a truthy value)}'
        include_examples 'is diffable' do
          let(:expected_structure) { arg }
        end
      end
    end

    context 'when the decoded actual does not match the hash' do
      let(:actual_original) do
        {
          foo: 1,
          bar: false
        }
      end

      context 'with positive expectation', :positive do
        include_examples 'fails', 'expected {"foo":1,"bar":false} to be JSON matching ' \
                                  '{:foo=>1, :bar=>(a truthy value)}'
        include_examples 'is diffable' do
          let(:expected_structure) { arg }
        end
      end

      context 'with negative expectation', :negative do
        include_examples 'passes'
      end
    end
  end

  context 'with an array' do
    let(:arg) do
      ['foo', a_string_starting_with('b')]
    end

    it 'provides description "be JSON matching EXPECTED"' do
      expect(matcher.description).to eq('be JSON matching ["foo", (a string starting with "b")]')
    end

    context 'when the decoded actual matches the array' do
      let(:actual_original) do
        %w[foo bar]
      end

      context 'with positive expectation', :positive do
        include_examples 'passes'
      end

      context 'with negative expectation', :negative do
        include_examples 'fails', 'expected ["foo","bar"] not to be JSON matching ' \
                                  '["foo", (a string starting with "b")]'
        include_examples 'is diffable' do
          let(:expected_structure) { arg }
        end
      end
    end

    context 'when the decoded actual does not match the array' do
      let(:actual_original) do
        ['foo', 1]
      end

      context 'with positive expectation', :positive do
        include_examples 'fails', 'expected ["foo",1] to be JSON matching ' \
                                  '["foo", (a string starting with "b")]'
        include_examples 'is diffable' do
          let(:expected_structure) { arg }
        end
      end

      context 'with negative expectation', :negative do
        include_examples 'passes'
      end
    end
  end

  context 'with a string' do
    let(:arg) do
      'foo'
    end

    it 'provides description "be JSON matching EXPECTED"' do
      expect(matcher.description).to eq('be JSON matching "foo"')
    end

    context 'when the decoded actual matches the string' do
      let(:actual_original) do
        'foo'
      end

      context 'with positive expectation', :positive do
        include_examples 'passes'
      end

      context 'with negative expectation', :negative do
        include_examples 'fails', 'expected "foo" not to be JSON matching "foo"'
        include_examples 'is diffable' do
          let(:expected_structure) { arg }
        end
      end
    end

    context 'when the decoded actual does not match the array' do
      let(:actual_original) do
        'bar'
      end

      context 'with positive expectation', :positive do
        include_examples 'fails', 'expected "bar" to be JSON matching "foo"'
        include_examples 'is diffable' do
          let(:expected_structure) { arg }
        end
      end

      context 'with negative expectation', :negative do
        include_examples 'passes'
      end
    end
  end

  context 'with a string' do
    let(:arg) do
      nil
    end

    it 'provides description "be JSON matching EXPECTED"' do
      expect(matcher.description).to eq('be JSON matching nil')
    end

    context 'when the decoded actual is nil' do
      let(:actual_original) do
        nil
      end

      context 'with positive expectation', :positive do
        include_examples 'passes'
      end

      context 'with negative expectation', :negative do
        include_examples 'fails', 'expected null not to be JSON matching nil'
        include_examples 'is diffable' do
          let(:expected_structure) { arg }
        end
      end
    end

    context 'when the decoded actual is not nil' do
      let(:actual_original) do
        false
      end

      context 'with positive expectation', :positive do
        include_examples 'fails', 'expected false to be JSON matching nil'
        include_examples 'is diffable' do
          let(:expected_structure) { arg }
        end
      end

      context 'with negative expectation', :negative do
        include_examples 'passes'
      end
    end
  end

  context 'with #including matcher' do
    let(:arg) do
      including(bar: 2)
    end

    it 'provides description "be JSON including EXPECTED"' do
      expect(matcher.description).to eq('be JSON including {:bar => 2}')
    end

    context 'when the decoded actual passes the #including matcher' do
      let(:actual_original) do
        {
          foo: 1,
          bar: 2
        }
      end

      context 'with positive expectation', :positive do
        include_examples 'passes'
      end

      context 'with negative expectation', :negative do
        include_examples 'fails', 'expected {"foo":1,"bar":2} not to be JSON including {:bar => 2}'
        include_examples 'is diffable' do
          let(:expected_structure) { { bar: 2 } }
        end
      end
    end
  end

  context 'with a non-JSON value', :positive do
    let(:arg) do
      Object.new
    end

    it 'raises ArgumentError' do
      expect { expectation }.to raise_error(ArgumentError)
    end
  end

  context 'with a BasicObject', :positive do
    let(:arg) do
      BasicObject.new
    end

    it 'raises ArgumentError' do
      expect { expectation }.to raise_error(ArgumentError)
    end
  end

  context 'when the actual cannot be parsed as JSON' do
    let(:actual_json) do
      'This is not valid JSON'
    end

    let(:arg) do
      {}
    end

    context 'with positive expectation', :positive do
      include_examples 'fails', [
        'cannot parse "This is not valid JSON" as JSON: ',
        ": unexpected token at 'This is not valid JSON'"
      ]
      include_examples 'is not diffable'
    end

    context 'with negative expectation', :negative do
      include_examples 'fails', [
        'cannot parse "This is not valid JSON" as JSON: ',
        ": unexpected token at 'This is not valid JSON'"
      ]
      include_examples 'is not diffable'
    end
  end

  context 'when ComposableJSONMatchers.configuration.parser_options is configured', :positive do
    before do
      RSpec::ComposableJSONMatchers.configure do |config|
        config.parser_options = { symbolize_names: false }
      end
    end

    let(:arg) do
      {
        'foo' => 1,
        'bar' => 2
      }
    end

    it 'parses JSON using the options' do
      expectation
    end
  end

  context 'when chained with `and`' do
    it 'makes compound expectations' do
      expect(actual_json).to be_json(actual_original).and be_a(String)
    end
  end
end
