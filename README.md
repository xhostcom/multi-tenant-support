# MultiTenantSupport

Multi-tenant buid on ActiveSupport::CurrentAttributes for Rails apps.
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'multi-tenant-support'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install multi-tenant-support

## Usage

Create a initialize file:

```ruby
# config/initializers/multi_tenant_support.rb

MultiTenantSupport.configure do |config|
  config.tenant_account_class = 'Account'
  config.primary_key = :id
  config.excluded_subdomains = ['www']
  config.current_tenant_account_method = :current_tenant_account
  config.host = 'example.com'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hoppergee/multi_tenant_support.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
