<p align="center">
  <img src="https://raw.githubusercontent.com/Fretadao/f_service/master/logo.png" height="150">

  <h1 align="center">FService</h1>

  <p align="center">
    <i>Simpler, safer and more composable operations</i>
    <br>
    <br>
    <img src="https://img.shields.io/gem/v/f_service">
    <img src="https://github.com/Fretadao/f_service/workflows/Ruby/badge.svg">
    <a href="https://github.com/Fretadao/f_service/blob/master/LICENSE">
      <img src="https://img.shields.io/github/license/Fretadao/f_service.svg" alt="License">
    </a>
  </p>
</p>

FService is a small gem that provides a base class for your services (aka operations).
The goal is to make services simpler, safer, and more composable.
It uses the Result monad for handling operations.

## Installation

Add this line to your application's Gemfile:

<!-- x-release-please-start-version -->
```ruby
gem 'f_service', '~> 0.4.1'
```
<!-- x-release-please-end-version -->

> The version above is kept current automatically on every release; pin to
> whichever version you prefer.

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install f_service

## Usage

### Creating your service

To start using it, you have to create your service class inheriting from FService::Base.

```ruby
class User::Create < FService::Base
end
```

Now, define your initializer to setup data.

```ruby
class User::Create < FService::Base
  def initialize(name:)
    @name = name
  end
end
```

The next step is writing the `#run` method, which is where the work should be done.
Use the methods `#Success` and `#Failure` to handle your return values.
You can optionally specify a list of types which represents that result and a value for your result.

```ruby
class User::Create < FService::Base
  # ...
  def run
    return Failure(:invalid_name, data: { name: ["can't be blank"] }) if @name.nil?

    user = UserRepository.create(name: @name)

    if user.save
      Success(:created, data: user)
    else
      Failure(:creation_failed, data: user.errors)
    end
  end
end
```

> Remember, you **have** to return an `FService::Result` at the end of your services.

> Always give your results a type. It says what happened, not just whether it worked, so
> callers can branch on the reason and a failure is readable in a log without opening the
> service. Pass the payload in `data:`, including on failures — otherwise `#error` is `nil`
> and whoever serializes it has nothing to show.

### Using your service

To run your service, use the method `#call` provided by `FService::Base`. We like to use the [implicit call](https://stackoverflow.com/a/19108981/8650655), but you can use it in the form you like most.

```ruby
User::Create.(name: name)
# or
User::Create.call(name: name)
```

> We do **not** recommend manually initializing and running your service because it **will not**
> type check your result (and you could lose nice features like [pattern
> matching](#pattern-matching) and [service chaining](#chaining-services))!

### Using the result

Use the methods `#successful?` and `#failed?` to check the status of your result. If it is successful, you can access the value with `#value`, and if your service fails, you can access the error with `#error`.

A hypothetical controller action using the example service could look like this:

```ruby
class UsersController < BaseController
  def create
    result = User::Create.(user_params)

    if result.successful?
      json_success(result.value)
    else
      json_error(result.error)
    end
  end
end
```

> Note that you're not limited to using services inside controllers. They're just PORO's (Plain Old Ruby Objects), so you can use in controllers, models, etc. (even other services!).

### Pattern matching

The code above could be rewritten using the `#on_success` and `#on_failure` hooks. They work similar to pattern matching:

```ruby
class UsersController < BaseController
  def create
    User::Create
      .call(user_params)
      .on_success { |user| return json_success(user) }
      .on_failure { |errors| return json_error(errors) }
  end
end
```

> You can ignore any of the callbacks, if you want to.

Once you start matching specific types (below), a result whose type none of the hooks
mention falls through untouched. Pass `unhandled: true` to run a callback for exactly those
leftovers:

```ruby
class UsersController < BaseController
  def create
    User::Create
      .call(user_params)
      .on_success(:created) { |user| return json_success(user) }
      .on_failure(unhandled: true) { |errors| return json_error(errors) }
  end
end
```

Going further, you can match the Result type, in case you want to handle them differently:

```ruby
class UsersController < BaseController
  def create
    User::Create
      .call(user_params)
      .on_success(:created) { |user| return json_success(user) }
      .on_failure(:invalid_name) { |errors| return json_error(errors) }
      .on_failure(:creation_failed) do |errors|
        MyLogger.report_failure(errors)

        return json_error(errors)
      end
  end
end
```

It's possible to provide multiple types to the hooks too. If the result type matches any of the given types,
the hook will run. Say the service also answers `Success(:already_exists, data: user)` when the
name is taken — both outcomes are fine for the caller:

```ruby
class UsersController < BaseController
  def create
    User::Create
      .call(user_params)
      .on_success(:created, :already_exists) { |user| return json_success(user) }
      .on_failure(:invalid_name) { |errors| return json_error(errors) }
      .on_failure(:creation_failed) do |errors|
        MyLogger.report_failure(errors)

        return json_error(errors)
      end
  end
end
```

### Type precedence

FService matches the service's types from left to right, from more specific to more generic.
For example, the following result `Failure(:unprocessable_entity, :client_error, :http_response)` will match in the following order:
1. `:unprocessable_entity`;
2. `:client_error`;
3. `:http_response`;
4. unmatched block;

### Chaining services

Since all services return Results, you can chain service calls making a data pipeline.
If some step fails, it will short circuit the call chain.

```ruby
class UsersController < BaseController
  def create
    result = User::Create
      .call(user_params)
      .and_then { |user| User::Login.(user) }
      .and_then { |user| User::SendWelcomeEmail.(user) }

    if result.successful?
      json_success(result.value)
    else
      json_error(result.error)
    end
  end
end
```

You can use the `.to_proc` method on FService::Base to avoid explicit inputs when chaining services:

```ruby
class UsersController < BaseController
  def create
    result = User::Create
      .call(user_params)
      .and_then(&User::Login)
      .and_then(&User::SendWelcomeEmail)
    # ...
  end
end
```

> **Coming from 0.2.x?** `Success#then` and `Failure#then` were deprecated in 0.3.0 and
> removed in 0.4.0. Use `#and_then`, which has always been their alias and behaves
> identically. Note that `#then` also exists on every Ruby object since 2.6, so a leftover
> call does not raise — it silently yields the Result itself instead of its value.

### `Check` and `Try`

You can use `Check` to convert a boolean into a Result: truthy values map to `Success`, falsey values to `Failure`.

```ruby
Check(:math_works) { 1 < 2 }
# => #<Success @value=true, @types=[:math_works]>

Check(:math_works) { 1 > 2 }
# => #<Failure @error=false, @types=[:math_works]>
```

`Try` transforms an exception into a `Failure` if some exception is raised for the given block. You can specify which exception class to watch for
using the parameter `catch`.

```ruby
class Number::DrawOdd < FService::Base
  def run
    Try(:drawn_number) do
      drawn_number = rand(1..10)
      raise "Yuck! It's a #{drawn_number}" if drawn_number.even?

      drawn_number
    end
  end
end

Number::DrawOdd.call
# => #<Success @value=9, @types=[:drawn_number]>

Number::DrawOdd.call
# => #<Failure @error=#<RuntimeError: Yuck! It's a 4>, @types=[:drawn_number]>
```

## Testing

We provide helpers and matchers to make it easier to test code involving FService services.

To make them available, add the following require to `spec/spec_helper.rb` or
`spec/rails_helper.rb`:

```ruby
require 'f_service/rspec'
```

### Mocking a result

`mock_service` stubs the service's `#call` and returns the Result you describe. It is a stub,
not a message expectation: it does not assert that the service was called, so add your own
`expect(...).to have_received(:call)` when that is the point of the test.

```ruby
mock_service(User::Create)
# => stubs a successful result, with no types and a nil value

mock_service(User::Create, result: :success, types: [:created])
# => stubs a Success typed :created

mock_service(User::Create, result: :success, types: [:created], value: instance_spy(User))
# => stubs a Success typed :created carrying a value

mock_service(User::Create, result: :failure, types: [:invalid_name])
# => stubs a Failure typed :invalid_name, with a nil error

mock_service(
  User::Create,
  result: :failure,
  types: [:invalid_name],
  value: { name: ["can't be blank"] }
)
# => stubs a Failure typed :invalid_name carrying an error
```

> `value:` fills `#value` on a Success and `#error` on a Failure — it is the payload either
> way. `types:` also accepts a bare symbol, but an array reads consistently. The deprecated
> singular `type:` argument was removed in 0.4.0.

Need the Result object itself rather than a stub — to pass it around in a unit test, say?
`f_service_result` builds one:

```ruby
result = f_service_result(:failure, { name: ["can't be blank"] }, [:invalid_name])
# => #<Failure @error={name: ["can't be blank"]}, @types=[:invalid_name]>
```

### Matching a result

```ruby
expect(User::Create.(name: 'Joe')).to have_succeed_with(:created)

expect(User::Create.(name: 'Joe')).to have_succeed_with(:created).and_value(an_instance_of(User))

expect(User::Create.(name: nil)).to have_failed_with(:invalid_name)

expect(User::Create.(name: nil))
  .to have_failed_with(:invalid_name).and_error({ name: ["can't be blank"] })

expect(User::Create.(name: nil))
  .to have_failed_with(:invalid_name).and_error(a_hash_including(name: ["can't be blank"]))
```

> The matchers compare the type list for **equality**, not inclusion. A service answering
> `Success(:created, :persisted)` is matched by `have_succeed_with(:created, :persisted)` —
> `have_succeed_with(:created)` alone fails. Name every type the result carries.

Putting it together, a spec for the service built above:

```ruby
RSpec.describe User::Create do
  subject(:create_user) { described_class.call(name: name) }

  context 'when the name is given' do
    let(:name) { 'Joe' }

    it { is_expected.to have_succeed_with(:created).and_value(an_instance_of(User)) }
  end

  context 'when the name is missing' do
    let(:name) { nil }

    it 'fails naming the offending attribute' do
      expect(create_user)
        .to have_failed_with(:invalid_name).and_error(a_hash_including(:name))
    end
  end
end
```

## API Docs

You can access the API docs [here](https://www.rubydoc.info/gems/f_service/).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that allows you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

Releases are automated: the version, the `CHANGELOG.md`, the git tag and the push to
[rubygems.org](https://rubygems.org) are all derived from
[Conventional Commits](https://www.conventionalcommits.org/) by release-please. There
is no version to edit and no release command to run by hand — see
[CONTRIBUTING.md](CONTRIBUTING.md).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Fretadao/f_service. Read [CONTRIBUTING.md](CONTRIBUTING.md) first — it covers the commit conventions the release automation depends on.

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
