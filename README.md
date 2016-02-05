# Fault Tolerant Capistrano

Imagine you have hundreds of hosts in Capistrano, and you'd like to allow specific command to fail on `5%` of your hosts.
The gem brings fault tolerant commands to Capistrano DSL:

```ruby
on roles(:web), failure_tolerance: 0.05 do
  within release_path do
    execute "./script-that-may-fail-sometimes"
  end
end
```


## Installation

Add this line to your application's Gemfile:

```ruby
# it's important to set `require: false`
gem 'capistrano-fault-tolerant', require: false
```

You'll also need the edge version of SSHKit which includes [the commit](https://github.com/capistrano/sshkit/commit/8d1ca5202cfd4dfd73b67412c99aafc655640060):

```
gem 'sshkit', github: 'capistrano/sshkit'
```

And then execute:

    $ bundle


## Usage

Add to `Capfile`:
```ruby
require 'capistrano-fault-tolerant'
```

Now you can use `failure_tolerance` option with any command:

```ruby
on roles(:web), failure_tolerance: 0.05 do
  within release_path do
    execute "./script-that-may-fail-sometimes"
  end
end
```

**If less than 5% of `web` hosts will fail, Capistrano will continue the deploy.

When more than 5% of `web` hosts will fail, Capistrano will stop with an exception as it usually does with failed commands.**

The gem can also call a callback on new failed host:

```
# config/deploy.rb
CapistranoFaultTolerant.on_failed_host = ->(host) {
  # notify someone about failed host
  puts "HOST FAILED: #{host}"
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/capistrano-fault-tolerant.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
