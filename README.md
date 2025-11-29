# BrowserOfBabel

[![CI](https://github.com/trinistr/browser_of_babel/actions/workflows/CI.yaml/badge.svg)](https://github.com/trinistr/browser_of_babel/actions/workflows/CI.yaml)

> [!TIP]
> You may be viewing documentation for an older (or newer) version of the gem than intended. Look at [Changelog](https://github.com/trinistr/browser_of_babel/blob/main/CHANGELOG.md) to see all versions, including unreleased changes.

***

A programmatic way to interact with the [Library of Babel](https://libraryofbabel.info): find pages, extract text and have fun.

**This project is not affiliated in any way with Library of Babel or Jonathan Basile.**

## Table of contents

- [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add to your application's Gemfile:

```ruby
gem "browser_of_babel", github: "trinistr/browser_of_babel"
```

## Usage

> [!NOTE]
> - Latest documentation from `main` branch is automatically deployed to [GitHub Pages](https://trinistr.github.io/browser_of_babel/).

> [!WARNING]
> `BrowserOfBabel` works by directly accessing the website to request text.
> This requires network connection and hits the server for every page requested,
> with no in-built caching or throttling.
> **Do not abuse this browser!**

### `BrowserOfBabel::Locator`

The most straightforward way to use `BrowserOfBabel` is to use `Locator`
to get specified characters from specified pages:

```ruby
# Locator instance can be reused, even across threads.
locator = BrowserOfBabel::Locator.new

# Open Hex 123az, Wall 1, Shelf 2, Volume 3, Page 4, take character 5:
locator.call("123az.1.2.3.4.5")
# => "q"

# Take characters 1-25 from the same page:
locator.call("123az.1.2.3.4.[1-25]")
# => "yrijqencpcup cnqf,gdaplod"

# Range syntax works only for characters, this is invalid!
locator.call("123az.1.2.3.[3-4].[1-25]")
# in `call': reference is invalid (ArgumentError)
```

You can also get the whole text from a page without referencing character ranges:

```ruby
locator.call("123az.1.2.3.4").text
# => "yrijqencpcup cnqf,gdaplodg,xj <... and so on>
```

References without character ranges can be used to get containers themselves, for custom processing, including references to higher-level containers:

```ruby
locator.call("123az.1.2")
# =>
# #<BrowserOfBabel::Shelf:0x00007f4cb28b7f58
#  @identifier=2,
#  @parent=
#   #<BrowserOfBabel::Wall:0x00007f4cb28b7fa8
#    @identifier=1,
#    @parent=
#     #<BrowserOfBabel::Hex:0x00007f4cb28b8048
#      @identifier="123az",
#      @parent=
#       #<BrowserOfBabel::Library:0x00007f4cb28b8070
#        @parent=nil>>>>
```

> [!NOTE]
> Referencing containers without actually accessing text does not make any requests.

`Locator` can be customized with a different reference format,
though be aware that it has assumptions about named captures:

```ruby
slash_reference_format =
  Regexp.new(BrowserOfBabel::Locator::DEFAULT_FORMAT.to_s.gsub("\\.", "/"))
locator = BrowserOfBabel::Locator.new(format: slash_reference_format)
locator.call("123az/1/2/3/4/[12-15]")
# => "p cn"
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests, `rake rubocop` to lint code and check style compliance, `rake rbs` to validate signatures or just `rake` to do everything above. There is also `rake steep` to check typing, and `rake docs` to generate YARD documentation.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `rake install`.

To release a new version, run `rake version:{major|minor|patch}`. After that, push the release commit and tags to the repository with `git push --follow-tags`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/trinistr/browser_of_babel.

### Checklist for a new or updated feature

- Running `rake spec` reports 100% coverage (unless it's impossible to achieve in one run).
- Running `rake rubocop` reports no offenses.
- Running `rake steep` reports no new warnings or errors.
- Tests cover the behavior and its interactions. 100% coverage *is not enough*, as it does not guarantee that all code paths are tested.
- Documentation is up-to-date: generate it with `rake docs` and read it.
- "*CHANGELOG.md*" lists the change if it has impact on users.
- "*README.md*" is updated if the feature should be visible there.

## License

This gem is available as open source under the terms of the MIT License, see [LICENSE.txt](https://github.com/trinistr/browser_of_babel/blob/main/LICENSE.txt).
