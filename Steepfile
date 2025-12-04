# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature "sig"

  check "lib"
  ignore "lib/browser_of_babel/holotheca/holarchy.rb"

  library "nokogiri"

  configure_code_diagnostics(D::Ruby.default)
  # configure_code_diagnostics(D::Ruby.strict)
  # configure_code_diagnostics(D::Ruby.lenient)
  # configure_code_diagnostics(D::Ruby.silent)
  # configure_code_diagnostics do |hash|
  #   hash[D::Ruby::NoMethod] = :information
  # end
end
