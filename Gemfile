# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rake", "~> 13.0", require: false

group :test do
  gem "rspec", "~> 3.0", require: false

  # Code coverage report
  gem "simplecov", require: false
end

group :linting do
  # Linting
  gem "rubocop", "~> 1.21", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-thread_safety", require: false

  # Checking type signatures
  gem "rbs", require: false
end

group :development do
  # Console and debugger
  gem "debug", require: false
  gem "irb", require: false

  # Version changes
  gem "bump", require: false

  # Type checking
  gem "steep", require: false

  # Documentation
  gem "yard", require: false
end
