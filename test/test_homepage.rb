require "minitest_helper"

class TestHomepage < Bridgetown::Test
  describe "index" do
    it "has a body and a head" do
      html get "/"

      expect(document.query_selector("body").inner_html).must_match(/<head.*?>/)
    end
  end
end
