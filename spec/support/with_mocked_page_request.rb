# frozen_string_literal: true

RSpec.shared_context "with mocked page request" do
  before { allow(Net::HTTP).to receive(:get).and_return(<<~HTML) }
    <html>
      <head>
        <title>jbcde 1</title>
      </head>
      <body>
        <!-- We use 40 characters per line, real ones have 80. -->
        <pre id="textblock">abcdefghijklmnopqrstuvwxyz12340987654321
    1234567890,. 1234567890,. 12340987654321</pre>
      </body>
    </html>
  HTML
end
