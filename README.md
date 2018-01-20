[![Gem Version](https://badge.fury.io/rb/rspec-composable_json_matchers.svg)](http://badge.fury.io/rb/rspec-composable_json_matchers)
[![Dependency Status](https://gemnasium.com/yujinakayama/rspec-composable_json_matchers.svg)](https://gemnasium.com/yujinakayama/rspec-composable_json_matchers)
[![Build Status](https://travis-ci.org/yujinakayama/rspec-composable_json_matchers.svg?branch=master&style=flat)](https://travis-ci.org/yujinakayama/rspec-composable_json_matchers)
[![Coverage Status](https://coveralls.io/repos/yujinakayama/rspec-composable_json_matchers/badge.svg?branch=master&service=github)](https://coveralls.io/github/yujinakayama/rspec-composable_json_matchers?branch=master)
[![Code Climate](https://codeclimate.com/github/yujinakayama/rspec-composable_json_matchers/badges/gpa.svg)](https://codeclimate.com/github/yujinakayama/rspec-composable_json_matchers)

# RSpec::ComposableJSONMatchers

**RSpec::ComposableJSONMatchers** provides `be_json` matcher,
which lets you express expected structures on JSON strings
with the power of RSpec's
[built-in matchers](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers)
and
[composable matchers](https://relishapp.com/rspec/rspec-expectations/docs/composing-matchers).

```ruby
json = '{ "foo": 1, "bar": 2 }'
expect(json).to be_json a_kind_of(Hash)
expect(json).to be_json matching(foo: 1, bar: a_kind_of(Integer))
expect(json).to be_json including(foo: 1)
```

## Installation

### Adding `rspec-composable_json_matchers` dependency

Add this line to your `Gemfile`:

```ruby
gem 'rspec-composable_json_matchers'
```

And then run:

```bash
$ bundle install
```

### Enabling `be_json` matcher

To make the `be_json` matcher available in every example,
add the following line to your `spec/spec_helper.rb`:

```ruby
# spec/spec_helper.rb
require 'rspec/composable_json_matchers/setup'
```

Or if you prefer more explicit way, add the following snippet:

```ruby
# spec/spec_helper.rb
require 'rspec/composable_json_matchers'

RSpec.configure do |config|
  config.include RSpec::ComposableJSONMatchers
end
```

If you want to enable the `be_json` matcher only specific examples rather than every example,
include the `RSpec::ComposableJSONMatchers` in the example groups:

```ruby
# spec/something_spec.rb
require 'rspec/composable_json_matchers'

describe 'something' do
  include RSpec::ComposableJSONMatchers
end
```

## Usage

The `be_json` matcher takes another matcher, a hash, or an array.

When a matcher is given,
it passes if actual string can be decoded as JSON and the decoded structure passes the given matcher:

```ruby
expect('{ "foo": 1, "bar": 2 }').to be_json a_kind_of(Hash)
expect('{ "foo": 1, "bar": 2 }').to be_json matching(foo: 1, bar: 2)
expect('{ "foo": 1, "bar": 2 }').to be_json including(foo: 1)

expect('["foo", "bar"]').to be_json a_kind_of(Array)
expect('["foo", "bar"]').to be_json matching(['foo', 'bar'])
expect('["foo", "bar"]').to be_json including('foo')
```

When a hash or an array is given,
it's handled as `be_json matching(hash_or_array)` (`matching` is an alias of the `match` matcher):

```ruby
# Equivalents
expect('{ "foo": 1, "bar": 2 }').to be_json(foo: 1, bar: 2)
expect('{ "foo": 1, "bar": 2 }').to be_json matching(foo: 1, bar: 2)
```

You can compose matchers via given matchers:

```ruby
expect('{ "foo": 1, "bar": 2 }').to be_json matching(
  foo: a_kind_of(Integer),
  bar: a_kind_of(Integer)
)

expect('{ "foo": 1, "bar": 2 }').to be_json including(foo: a_kind_of(Integer))
```

For more practical example, see
[`spec/example_spec.rb`](https://github.com/yujinakayama/rspec-composable_json_matchers/blob/master/spec/example_spec.rb)
for the [GitHub Meta API](https://developer.github.com/v3/meta/).

## Combinations with built-in matchers

Since decoded JSON is always a hash or an array, you may want to use any of the following built-in matchers.

Note that you can always use the `match` matcher (internally uses `#===`)
instead of the `eq` matcher (internally uses `#==`),
because there's no object that is parsed from JSON and behaves differently between `#==` and `#===`.

Of course, any other custom matchers supporting a hash or an array can also be used.

### `matching`

* Alias of [`match`](https://relishapp.com/rspec/rspec-expectations/docs/composing-matchers#composing-matchers-with-`match`:) matcher
* Supported structure: Hash and Array
* Accepts matchers as arguments: Yes

```ruby
expect('{ "foo": 1, "bar": 2 }').to be_json matching(foo: 1, bar: a_kind_of(Integer))
expect('["foo", "bar"]').to be_json matching(['foo', a_string_starting_with('b')])
```

### `including`

* Alias of [`include`](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/include-matcher#hash-usage) matcher
* Supported structure: Hash and Array
* Accepts matchers as arguments: Yes

```ruby
expect('{ "foo": 1, "bar": 2 }').to be_json including(foo: 1)
expect('["foo", "bar"]').to be_json including('foo')
```

### `all`

* [`all`](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/all-matcher) matcher
* Supported structure: Array
* Accepts matchers as arguments: Yes

```ruby
expect('["foo", "bar"]').to be_json all be_a(String)
```

### `containing_exactly`

* Alias of [`contain_exactly`](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/contain-exactly-matcher) matcher
* Supported structure: Array
* Accepts matchers as arguments: Yes

```ruby
expect('["foo", "bar"]').to be_json containing_exactly('bar', 'foo')
```

### `starting_with`

* Alias of [`start_with`](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/start-with-matcher) matcher
* Supported structure: Array
* Accepts matchers as arguments: Yes

```ruby
expect('["foo", "bar"]').to be_json starting_with('foo')
```

### `ending_with`

* Alias of [`end_with`](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/end-with-matcher) matcher
* Supported structure: Array
* Accepts matchers as arguments: Yes

```ruby
expect('["foo", "bar"]').to be_json ending_with('bar')
```

### `having_attributes`

* Alias of [`have_attributes`](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/have-attributes-matcher) matcher
* Supported structure: Hash and Array
* Accepts matchers as arguments: Yes

```ruby
expect('{ "foo": 1, "bar": 2 }').to be_json having_attributes(keys: [:foo, :bar])
expect('["foo", "bar"]').to be_json having_attributes(size: 2)
```

### `a_kind_of`

* Alias of [`be_a_kind_of`](https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/type-matchers#be-(a-)kind-of-matcher) matcher
* Supported structure: Hash and Array
* Accepts matchers as arguments: No

```ruby
expect('{}').to be_json a_kind_of(Hash)
expect('[]').to be_json a_kind_of(Array)
```

## Configuration

The `be_json` matcher internally uses
[`JSON.parse`](http://ruby-doc.org/stdlib-2.3.0/libdoc/json/rdoc/JSON.html#method-i-parse)
to decode JSON strings.
The default parser options used in the `be_json` matcher is `{ symbolize_names: true }`,
so you need to pass _a hash with symbol keys_ as an expected structure.

If you prefer string keys, add the following snippet to your `spec/spec_helper.rb`:

```ruby
# spec/spec_helper.rb
RSpec::ComposableJSONMatchers.configure do |config|
  config.parser_options = { symbolize_names: false }
end
```

## License

Copyright (c) 2016 Yuji Nakayama

See the [LICENSE.txt](LICENSE.txt) for details.
