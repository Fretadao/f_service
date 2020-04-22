# FService

FService is a small gem that provides a base class for your services (aka operations).
The goal is to make services simpler, safer and more composable.
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

To start using it, you have to create your service class inheriting from FService::Base.

```ruby
class User::UpdateName < FService::Base
end
```

Now, define your initializer to setup data.
```ruby
class User::UpdateName < FService::Base
  def initialize(user:, new_name:)
    @user = user
    @new_name = new_name
  end
end
```

The next step is writing the `#run` method, which is where the work should be done.
Use the methods `#success` and `#failure` to handle your return values. The return can be any value.

```ruby
class User::UpdateName < FService::Base
  # ...
  def run
    return failure("No user given") if @user.nil?

    if @user.update(name: @new_name)
      success(status: "Updated", data: @user)
    else
      failure(status: "Name not updated", data: @user.errors)
    end
  end
end
```

To use your service use the method `#call` provided by `FService::Base`. We like to use the [implicit call](https://stackoverflow.com/questions/19108550/how-does-rubys-operator-work) but you can use it in the form you like most.

```ruby
User::UpdateName.(user: user, new_name: new_name)
```

> Remember, you **have** to return an `FService::Result` at the end of your services.

You can access the API docs [here](https://www.rubydoc.info/gems/f_service/).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Fretadao/f_service.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
