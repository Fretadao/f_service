![CI](https://github.com/Fretadao/f_service/workflows/Ruby/badge.svg)

# FService

FService is a small gem that provides a base class for your services (aka operations).
The goal is to make services simpler, safer, and more composable.
It uses the Result monad for handling operations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'f_service'
```

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
Use the methods `#success` and `#failure` to handle your return values. The return can be any value.

```ruby
class User::Create < FService::Base
  # ...
  def run
    return failure("No name given") if @name.nil?

    user = UserRepository.create(name: @name)
    if user.valid?
      success(status: "User successfully created!", data: user)
    else
      failure(status: "User could not be created!", data: user.errors)
    end
  end
end
```
> Remember, you **have** to return an `FService::Result` at the end of your services.

### Using your service

To run your service, use the method `#call` provided by `FService::Base`. We like to use the [implicit call](https://stackoverflow.com/a/19108981/8650655), but you can use it in the form you like most.

```ruby
User::Create.(name: name)
# or
User::Create.call(name: name)
```

> We do **not** recommend manually initializing your service because it **will not** type check your result (and you could lose nice features like [pattern matching](#pattern-matching) and [service chaining](#chaining-services))!

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
> Note that you're not limited to using services inside controllers. They're just PORO's (Play Old Ruby Objects), so you can use in controllers, models, etc. (even other services!).

### Pattern matching
The code above could be rewritten using the `#on` matcher too. It works similar to pattern matching:

```ruby
class UsersController < BaseController
  def create
    User::Create.(user_params).on(
      success: ->(value) { return json_success(value) },
      failure: ->(error) { return json_error(error) }
    )
  end
end
```
> You can use any object that responds to #call, not only Lambdas.

### Chaining services
Since all services return Results, you can chain service calls making a data pipeline.
If some step fails, it will short circuit the call chain.

```ruby
class UsersController < BaseController
  def create
    result = User::Create.(user_params)
                         .then { |user| User::Login.(user) }
                         .then { |user| User::SendWelcomeEmail.(user) }

    if result.successful?
      json_success(result.value)
    else
      json_error(result.error)
    end
  end
end
```

## API Docs

You can access the API docs [here](https://www.rubydoc.info/gems/f_service/).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that allows you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Fretadao/f_service.

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
