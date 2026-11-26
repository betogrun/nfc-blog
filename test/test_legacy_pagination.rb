require "minitest_helper"

# Jekyll paginated the home 4 posts a page, so /posts/page/2/ to /4/ are legacy URLs.
# At 8 a page fewer pages exist; the numbers past the last one forward to it.
class TestLegacyPagination < Bridgetown::Test
  SITE = "https://blog.albertorocha.me".freeze
  LAST_LEGACY_PAGE = 4
  POST_COUNT = Dir[File.expand_path("../src/_posts/*.md", __dir__)].count do |path|
    !File.read(path).match?(/^published: false$/)
  end
  LAST_PAGE = (POST_COUNT / 8.0).ceil
  TARGET = LAST_PAGE == 1 ? "/" : "/posts/page/#{LAST_PAGE}/"

  ((LAST_PAGE + 1)..LAST_LEGACY_PAGE).each do |number|
    path = "/posts/page/#{number}/"

    describe path do
      it "forwards to the last page and stays out of search" do
        response = get path
        html response

        assert_predicate response, :ok?
        assert_equal(["noindex"], document.query_selector_all("meta[name='robots']").map { it[:content] })
        assert_equal "#{SITE}#{TARGET}", document.query_selector("link[rel='canonical']")[:href]
        assert_equal "0; url=#{TARGET}", document.query_selector("meta[http-equiv='refresh']")[:content]
        assert_equal TARGET, document.query_selector("body a")[:href]
      end

      it "is left out of the sitemap" do
        html get "/sitemap.xml"

        refute_includes document.query_selector_all("loc").map(&:text), "#{SITE}#{path}"
      end
    end
  end
end
