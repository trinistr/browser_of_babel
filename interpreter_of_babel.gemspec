# frozen_string_literal: true

require_relative "lib/interpreter_of_babel/version"

Gem::Specification.new do |spec|
  spec.name = "interpreter_of_babel"
  spec.version = InterpreterOfBabel::VERSION
  spec.authors = ["Alexandr Bulancov"]
  spec.email = ["6594487+trinistr@users.noreply.github.com"]

  spec.summary = "TODO: Write a short summary, because RubyGems requires one."
  spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/trinistr/interpreter_of_babel"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files =
    IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
      ls.each_line("\x0", chomp: true).reject do |f|
        (f == gemspec) ||
          f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
      end
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.0"
end
