# BrowserOfBabel

A programmatic way to interact with the [Library of Babel](https://libraryofbabel.info).

**This project is not affiliated in any way with Library of Babel or Jonathan Basile.**

## Installation

Add to Gemfile:

```ruby
gem "browser_of_babel", github: "trinistr/browser_of_babel"
```

## Usage

> [!important]
> `BrowserOfBabel` works by directly accessing the website when referencing text.
> To get strings from the Library, network requests are performed.
> **Do not abuse this browser!**

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

> [!note]
> Referencing containers without actually accessing text does not make any requests.

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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/trinistr/browser_of_babel.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
