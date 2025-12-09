# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Next]

**Added**
- `BrowserOfBabel::Randomizer` for generating random holothecas (or just their identifiers).
- `Volume#title`.
- Pattern matching of holothecas with array patterns via `Holotheca#path_identifers`, aliased as `#deconstruct`.
- `Locator#from_identifiers`, accepting a list of identifiers and an array of ranges to extract text.

**Changed**
- [BREAKING] Rename `browse_babel` executable to `browser_of_babel` for consistency.
- Allow `Holotheca` to use identifiers that aren't Integer or String; now any value is supported, with baked-in conversion added for Symbol.
- Make `Holotheca` more resilient to different `.identifier_format`s, should now support pretty much any case, including re-setting it to `nil`.
- Rename `Page#book_title` to `Page#volume_title`.

**Fixed**
- `Holotheca#path`, `#root` and `#depth` now all work correctly even if holarchy is changed after instantiation, checking the actual parents, not classes.

## [v0.1.0] — 2025-04-07

First really useful version.

**Added**
- `BrowserOfBabel::Locator` with `#call` to find holothecas and text by reference.

**Changed**
- Make `Page#[]` also accept single numbers to return one character, in addition to ranges and start-length pair.
- Change more internal methods.

**Removed**
- `BrowserOfBabel::Finder` in favor of `BrowserOfBabel::Locator`.

## [v0.1.0-alpha2] — 2025-11-30

Original idea to "interpret" the texts was dropped in favor of just making this a browser.

**Changed**
- Rename `InterpreterOfBabel` to `BrowserOfBabel`.
- Rename `InterpreterOfBabel::Container` to `BrowserOfBabel::Holotheca` to smart.
- Add more methods to `Holotheca` to simplify subclasses.

**Added**
- A few methods of `Holotheca`.

## [v0.1.0-alpha1] — 2025-03-30

First implementation.

**Added**
- `InterpreterOfBabel::Container` class and its subclasses: `Library`, `Hex`, `Wall`, `Shelf`, `Volume`, `Page`, with methods to navigate the library.
- `InterpreterOfBabel::PageContent` which fetches the actual page and allows to access its content.
- `InterpreterOfBabel::Finder` with `#call` to find page by full address.

[Next]: https://github.com/trinistr/browser_of_babel/tree/main
[v0.1.0]: https://github.com/trinistr/browser_of_babel/tree/v0.1.0
[v0.1.0-alpha2]: https://github.com/trinistr/browser_of_babel/tree/v0.1.0-alpha2
[v0.1.0-alpha1]: https://github.com/trinistr/browser_of_babel/tree/v0.1.0-alpha1
