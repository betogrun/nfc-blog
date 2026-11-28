require "minitest_helper"

# One Atom feed per language (#127): /feed.xml stays English, /pt/feed.xml is Portuguese.
class TestPortugueseFeed < Bridgetown::Test
  GEMS_PT = "/pt/posts/publishing-ruby-gems-with-github-actions".freeze

  describe "feeds" do
    it "has a Portuguese feed with only the Portuguese posts" do
      feed = html get("/pt/feed.xml")
      links = feed.query_selector_all("entry link[rel='alternate']").map { it[:href] }

      assert_includes links, "https://blog.albertorocha.me#{GEMS_PT}"
      assert_empty(links.reject { it.start_with?("https://blog.albertorocha.me/pt/") })
      assert_equal "pt-BR", feed.query_selector("feed")["xml:lang"]
    end

    it "links each page to the feed in its language" do
      html get GEMS_PT

      assert_equal "https://blog.albertorocha.me/pt/feed.xml",
                   document.query_selector("link[type='application/atom+xml']")[:href]
      assert_equal "/pt/feed.xml", document.query_selector(".site-footer a[aria-label='Feed RSS']")[:href]
    end
  end
end
