# Rekord Export

This gem converts a Rekordbox collection `rekordbox.xml` to M3U playlists and iTunes' `library.xml` 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rekord_export'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rekord_export

## Usage

```bash
# It will create files in the current directory
rekord_export /path/to/rekordbox.xml 
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rekord_export.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
