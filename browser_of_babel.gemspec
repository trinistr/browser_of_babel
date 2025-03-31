# frozen_string_literal: true

require_relative "lib/browser_of_babel/version"

Gem::Specification.new do |spec|
  spec.name = "browser_of_babel"
  spec.version = BrowserOfBabel::VERSION
  spec.authors = ["Alexandr Bulancov"]
  spec.email = ["6594487+trinistr@users.noreply.github.com"]

  spec.summary = "A programmatic way to interact with the Library of Babel"
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/trinistr/browser_of_babel"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
      ls.each_line("\x0", chomp: true).select { |f| f.start_with?(*%w[lib/ sig/]) }
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  spec.extra_rdoc_files = ["README.md", "CHANGELOG.md"]
  spec.rdoc_options << "--main" << "README.md"

  spec.add_dependency "net-http", "~> 0.6"
  spec.add_dependency "nokogiri", "~> 1.0"
end
