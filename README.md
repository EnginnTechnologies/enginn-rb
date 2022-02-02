# Enginn

The official gem to interact with the [Enginn API](https://app.enginn.tech/api/docs/index.html).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'enginn'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install enginn

## Usage

```rb
# Create a client
client = Enginn::Client.new(api_token: 'xxxxx')

# Retrieve a project
project = client.projects('xxxxx')

# Manipulate collections
characters = project.characters(gender_eq: 'male') # fitlers
characters.each do |character|
    # ...
end

# Update a character
character = project.characters('xxxxx').fetch!
character.name = 'Pilou'
character.save!

# Create a new character
character = Enginn::Character.new(project, name: 'Raph', gender: 'male', ...)
character.save!

# Destroy a character
character.destroy!
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/EnginnTechnologies/enginn-rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
