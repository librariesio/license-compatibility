# License::Compatibility

Check compatibility between different SPDX licenses, used by [Libraries.io](https://libraries.io) for checking dependency license compatibility.

[![Build Status](https://travis-ci.org/librariesio/license-compatibility.svg?branch=master)](https://travis-ci.org/librariesio/license-compatibility)
[![Code Climate](https://img.shields.io/codeclimate/github/librariesio/license-compatibility.svg?style=flat)](https://codeclimate.com/github/librariesio/license-compatibility)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/librariesio/license-compatibility.svg?style=flat)](https://codeclimate.com/github/librariesio/license-compatibility)
[![Code Climate](https://img.shields.io/codeclimate/issues/github/librariesio/license-compatibility.svg)](https://codeclimate.com/github/librariesio/license-compatibility/issues)
[![license](https://img.shields.io/github/license/librariesio/license-compatibility.svg)](https://github.com/librariesio/license-compatibility/blob/master/LICENSE.txt)

*n.b. I am not a lawyer and any results should be confirmed with a copyright lawyer if it's important to you.*

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'license-compatibility'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install license-compatibility

## Usage

On the command-line:

`license-compatibility [-h] [-v] [-l] [-r file] [args]`

Arguments are a list of licenses or a list of package:license couples.
Examples:
```
license-compatibility MIT GPL-3.0 Unlicense
license-compatibility my_package:ISC other_pkg:BSD-2-Clause
```
Mixing the two formats is not allowed.
Additional args after a --read option are accepted.

Options:
- **-l, --list**: Print the list of supported licenses.
- **-r, --read FILE**: Read arguments from file.
- **-v, --version**: Show the program version.
- **-h, --help**: Print help message.


In your code:

```ruby
License::Compatibility.forward_compatibility('MIT', 'GPL-3.0') #=> true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/librariesio/license-compatibility. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
