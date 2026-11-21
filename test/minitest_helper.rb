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

# Minitest turns on deprecation warnings. yell (html-proofer's logger, last released in 2020)
# appends to a string literal, which Ruby 4 warns about on every check_links run.
module YellWarningFilter
  def warn(message, ...)
    super unless message.include?("/gems/yell-")
  end
end
Warning.singleton_class.prepend(YellWarningFilter)
