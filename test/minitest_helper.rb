ENV["MT_NO_EXPECTATIONS"] = "true"
require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::ProgressReporter.new]

require "bridgetown/test"

module Bridgetown
  class Test
    # Rack returns the body as binary, and Nokolexbor turns every non-ASCII byte of a
    # binary string into U+FFFD. Tag it as UTF-8 (the site's charset) before parsing.
    def html(response) = @document = Nokolexbor::Document.parse(response.body.dup.force_encoding(Encoding::UTF_8))
  end
end
