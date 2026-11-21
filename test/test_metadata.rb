require "minitest_helper"

# Feed, sitemap and <head> metadata. Every URL a crawler or feed reader sees must be
# absolute and on https, and each page must carry a single set of metadata.
class TestMetadata < Bridgetown::Test
  SITE = "https://blog.albertorocha.me".freeze
  LEGACY_PATHS = File.readlines(File.expand_path("fixtures/legacy_urls.txt", __dir__), chomp: true)
                     .reject { it.empty? || it.start_with?("#") }
  POST_COUNT = Dir[File.expand_path("../src/_posts/*.md", __dir__)].count do |path|
    !File.read(path).match?(/^published: false$/)
  end

  def xml(path)
    html get(path)
  end

  def meta(property)
    document.query_selector_all("meta[property='#{property}'], meta[name='#{property}']").map { it[:content] }
  end

  describe "feed" do
    it "lists the posts with absolute https links" do
      feed = xml("/feed.xml")
      links = feed.query_selector_all("entry link[rel='alternate']").map { it[:href] }

      assert_equal [POST_COUNT, 10].min, links.size
      assert_empty(links.reject { it.start_with?("#{SITE}/posts/") })
    end

    it "links to pages the site serves" do
      urls = xml("/feed.xml").query_selector_all("link[href]").map { it[:href] }

      assert_empty(urls.reject { get(it.delete_prefix(SITE)).ok? })
    end

    it "is linked from every page" do
      html get "/"

      assert_equal 1, document.query_selector_all("link[type='application/atom+xml']").size
    end
  end

  describe "sitemap" do
    # The Jekyll sitemap left out the tag cloud (`sitemap: false`) and pagination pages.
    it "lists every legacy URL the Jekyll sitemap had" do
      locs = xml("/sitemap.xml").query_selector_all("loc").map(&:text)
      expected = LEGACY_PATHS.reject { it == "/tags" || it.start_with?("/posts/page/") }

      assert_empty expected.map { "#{SITE}#{it}" } - locs
    end

    it "only has absolute https URLs and no dependency files" do
      locs = xml("/sitemap.xml").query_selector_all("loc").map(&:text)

      assert_empty(locs.reject { it.start_with?("#{SITE}/") })
      assert_empty locs.grep(/node_modules/)
    end

    # html-proofer only reads HTML, so the URLs in the sitemap are checked here.
    it "only lists pages the site serves" do
      locs = xml("/sitemap.xml").query_selector_all("loc").map(&:text)

      assert_empty(locs.reject { get(it.delete_prefix(SITE)).ok? })
    end

    it "is announced in robots.txt" do
      assert_includes get("/robots.txt").body, "Sitemap: #{SITE}/sitemap.xml"
    end
  end

  describe "head" do
    %w[/ /posts/overwriting-pagy-navigation-helper /tag/pagy/ /about].each do |path|
      it "has one set of absolute metadata on #{path}" do
        html get path

        %w[description og:title og:description og:url og:image og:type twitter:card].each do |name|
          assert_equal 1, meta(name).size, "#{name} on #{path}"
        end
        assert_equal "#{SITE}#{path}", meta("og:url").first
        assert_equal "#{SITE}/images/og-image.jpg", meta("og:image").first
        assert_equal "summary", meta("twitter:card").first
        assert_equal ["@betogrun"], meta("twitter:creator")
      end
    end

    it "keeps the Jekyll title format" do
      html get "/posts/overwriting-pagy-navigation-helper"

      assert_match(/\ANotes from a coder \| \S/, document.query_selector("title").text)
      assert_equal 1, document.query_selector_all("title").size
    end
  end

  describe "open graph" do
    it "marks posts as articles and other pages as websites" do
      html get "/posts/overwriting-pagy-navigation-helper"

      assert_equal ["article"], meta("og:type")

      html get "/"

      assert_equal ["website"], meta("og:type")
      assert_empty meta("article:published_time")
    end

    it "uses the post description, with smart quotes" do
      html get "/posts/overwriting-pagy-navigation-helper"
      post = Dir[File.expand_path("../src/_posts/*overwriting-pagy*.md", __dir__)].first
      description = File.read(post)[/^description: "(.*)"$/, 1].tr("'", "’")

      assert_equal [description], meta("description")
      assert_equal [description], meta("og:description")
    end
  end
end
