require "minitest_helper"

# Post dates follow the page's language (#127).
class TestLocalizedDates < Bridgetown::Test
  GEMS = "/posts/publishing-ruby-gems-with-github-actions".freeze
  GEMS_PT = "/pt#{GEMS}".freeze

  describe "dates" do
    it "shows them the Brazilian way, keeping ISO in the datetime attribute" do
      html get GEMS_PT

      time = document.query_selector(".article-header time")

      assert_equal ["01/09/2024", "2024-09-01"], [time.text, time[:datetime]]

      html get "/pt/"

      assert_equal "01/09/2024", document.query_selector(".article-list-meta time").text
    end

    it "keeps ISO dates in English" do
      html get GEMS

      assert_equal "2024-09-01", document.query_selector(".article-header time").text
    end
  end
end
