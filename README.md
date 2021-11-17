[![CircleCI](https://circleci.com/gh/seesaw/onpage_ruby/tree/main.svg?style=svg)](https://circleci.com/gh/seesaw/onpage_ruby/tree/s&m)

## WARNING: this software is a pre-release quality, features are provided “as is”, “with all faults”, and without any warranties, guarantees, or conditions of any kind. Your use of pre-release features are at your own risk.

### TODO
- [ ] setup CI on CircleCI
  - [x] test against multiple interpreters
  - [ ] add rubocop jobs
  - [ ] add coverage job
- [ ] improve test suite
    - [ ] fix on demand nested relation test
    - [ ] fix preloading things test
    - [ ] add coverage support
- [ ] make rubocop happy
- [ ] release the gem to rubygems.org
  - [ ] add changelog file
- [ ] add create/update object support
- [ ] add delete object support

# Onpage::Ruby

This gem is the Ruby client library that helps connect Ruby applications to the OnPage PIM (https://onpage.it).
Heavily inspired by the "official" [php code](https://github.com/onpage-dev/onpage-php).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'onpage_ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install onpage_ruby

## Usage

Once the gem is installed, you can call OnPage APIs like this:

```ruby
require 'onpage'

# Construct the OnPage Client
OnPage.configure do |config|
    config.api_key '<YOUR_API_KEY>',
    config.company '<YOUR_COMPANY_CODE>'
end

# Create a query criteria...
criteria = OnPage::Api::Criteria.new("posts")
                                .with('comments.mentions')
                                .where("title", "like", "led")
                                .all
# ... retrieve and ...
chapters = OnPage::Api.query(criteria)

# ... access data
author = chapters.last.val('author')
mentions = chapters.rel('comments.mentions')
mentions.first
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/seesaw/onpage_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/seesaw/onpage_ruby/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Onpage::Ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/seesaw/onpage_ruby/blob/master/CODE_OF_CONDUCT.md).
