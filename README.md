# Activestorage::Ftp

Active Storage FTP Service, This project only support FTP service not SSH

[![Build Status](https://travis-ci.org/iscreen/active-storage-ftp.svg)](https://travis-ci.org/iscreen/active-storage-ftp)
[![CircleCI](https://circleci.com/gh/iscreen/active-storage-ftp.svg?style=svg)](https://circleci.com/gh/iscreen/active-storage-ftp)
[![Gem Version](https://badge.fury.io/rb/active-storage-ftp.svg)](https://badge.fury.io/rb/active-storage-ftp)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'actives-storage-ftp'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active-storage-ftp

## Usage

```yml
production:
  service: FTP
  host: <%= ENV["FTP_HOST"] %>
  port: <%= ENV["FTP_PORT"] %>
  username: <%= ENV["FTP_USERNAME"] %>
  password: <%= ENV["FTP_PASSWORD"] %>
  folder: <%= ENV["FTP_FOLDER"] %>
  url: <%= ENV["FTP_URL"] %>
  # optional
  passive: true
  ssl: false
  debug_mode: false
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iscreen/actives-torage-ftp.
