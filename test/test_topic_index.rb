require "minitest_helper"

# The alphabetical list of topics (tags) that closes every home page and makes up the
# Topics page (#141).
class TestTopicIndex < Bridgetown::Test
  POSTS = Dir[File.expand_path("../src/_posts/*.md", __dir__)].reject { it.end_with?(".pt.md") }.filter_map do |path|
    front_matter = YAML.safe_load(File.read(path)[/\A---\n(.*?)\n---/m, 1], permitted_classes: [Date])
    front_matter unless front_matter["published"] == false
  end
  COUNTS = POSTS.flat_map { it.fetch("tags", []) }.tally

  def entries = document.query_selector_all(".topic-index li a")

  def names = entries.map { it.query_selector(".topic-index-name").text.strip }

  def counts = entries.to_h { [it[:href], it.query_selector(".topic-index-count").text.strip.to_i] }

  describe "on the home" do
    it "follows the pagination, under a Topics heading" do
      html get "/"

      index = document.query_selector("nav.article-pagination + .topic-index")

      assert_equal "Topics", index.query_selector("h2").text.strip
    end

    it "lists every topic with posts, with its count, linking to its page" do
      html get "/"

      assert_equal COUNTS.to_h { ["/tag/#{it}/", COUNTS[it]] }, counts
    end

    it "orders the topics by name" do
      html get "/"

      assert_equal names.sort_by { it.unicode_normalize(:nfd).downcase }, names
    end

    it "closes the other home pages too" do
      html get "/posts/page/2/"

      refute_nil document.query_selector("nav.article-pagination + .topic-index")
    end
  end

  describe "in Portuguese" do
    it "uses the translated heading, names and paths" do
      html get "/pt/"

      assert_equal "Assuntos", document.query_selector(".topic-index h2").text.strip
      assert_includes names, "Automação"
      assert_equal COUNTS["ruby"], counts["/pt/tag/ruby/"]
    end
  end

  describe "Topics page" do
    it "is the index under its own title, with no cloud" do
      html get "/tags"

      assert_equal "Topics", document.query_selector(".tags-page h1").text.strip
      assert_equal "#{COUNTS.size} topics across #{POSTS.size} posts",
                   document.query_selector(".tags-page .tags-page-count").text.strip
      assert_nil document.query_selector(".topic-index h2")
      assert_equal COUNTS.size, entries.size
      assert_empty document.query_selector_all(".tag-cloud")
    end

    it "is Assuntos in Portuguese" do
      html get "/pt/tags"

      assert_equal "Assuntos", document.query_selector(".tags-page h1").text.strip
      assert_includes document.query_selector("title").text, "Assuntos"
      assert_equal "#{COUNTS.size} assuntos em #{POSTS.size} posts",
                   document.query_selector(".tags-page .tags-page-count").text.strip
    end
  end
end
